//
//  TodoListViewModel.swift
//  TodoListTest
//

import Foundation
import Combine

@MainActor
final class TodoListViewModel: ObservableObject {
    @Published var todos: [Todo] = Todo.sampleData
    @Published var searchQuery: String = ""
    @Published var path: [Todo] = []

    var displayedTodos: [Todo] {
        let query = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let filtered: [Todo]
        if query.isEmpty {
            filtered = todos
        } else {
            filtered = todos.filter { todo in
                todo.title.lowercased().contains(query)
                    || todo.details.lowercased().contains(query)
            }
        }
        return filtered.sorted { $0.updatedAt > $1.updatedAt }
    }

    func toggle(_ todo: Todo) {
        guard let index = todos.firstIndex(where: { $0.id == todo.id }) else { return }
        todos[index].isCompleted.toggle()
    }

    func delete(_ todo: Todo) {
        todos.removeAll { $0.id == todo.id }
    }

    func save(_ todo: Todo) {
        var bumped = todo
        bumped.updatedAt = Date()
        if let index = todos.firstIndex(where: { $0.id == bumped.id }) {
            todos[index] = bumped
        } else {
            todos.append(bumped)
        }
    }

    func startNewTodo() {
        path.append(Todo(title: ""))
    }
}
