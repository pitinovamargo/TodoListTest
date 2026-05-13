//
//  TodoListViewModel.swift
//  TodoListTest
//

import Foundation
import Combine

@MainActor
final class TodoListViewModel: ObservableObject {
    @Published var todos: [Todo] = []
    @Published var searchQuery: String = ""
    @Published var path: [Todo] = []

    private let storage: TodoStorageProtocol
    private let api: TodoAPIServiceProtocol
    private let initialLoadFlag: InitialLoadFlag
    private var cancellables = Set<AnyCancellable>()

    init(
        storage: TodoStorageProtocol,
        api: TodoAPIServiceProtocol,
        initialLoadFlag: InitialLoadFlag
    ) {
        self.storage = storage
        self.api = api
        self.initialLoadFlag = initialLoadFlag
        bindSearch()
    }

    func load() async {
        do {
            if !initialLoadFlag.isSet {
                let imported = try await api.fetchTodos()
                try await storage.save(imported)
                initialLoadFlag.set()
            }
            todos = try await storage.search(searchQuery)
        } catch {
            print("Не удалось загрузить задачи: \(error)")
        }
    }

    func toggle(_ todo: Todo) {
        guard let index = todos.firstIndex(where: { $0.id == todo.id }) else { return }
        todos[index].isCompleted.toggle()
        persist(todos[index])
    }

    func delete(_ todo: Todo) {
        todos.removeAll { $0.id == todo.id }
        Task {
            try? await storage.delete(id: todo.id)
        }
    }

    func save(_ todo: Todo) {
        var bumped = todo
        bumped.updatedAt = Date()
        if let index = todos.firstIndex(where: { $0.id == bumped.id }) {
            todos[index] = bumped
        } else {
            todos.append(bumped)
        }
        todos.sort { $0.updatedAt > $1.updatedAt }
        persist(bumped)
    }

    func startNewTodo() {
        path.append(Todo(title: ""))
    }

    private func bindSearch() {
        $searchQuery
            .removeDuplicates()
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { [weak self] query in
                self?.runSearch(query)
            }
            .store(in: &cancellables)
    }

    private func runSearch(_ query: String) {
        Task { [weak self] in
            guard let self else { return }
            do {
                let results = try await self.storage.search(query)
                self.todos = results
            } catch {
                print("Поиск не удался: \(error)")
            }
        }
    }

    private func persist(_ todo: Todo) {
        Task {
            try? await storage.save(todo)
        }
    }
}
