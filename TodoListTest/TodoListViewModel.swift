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

    func toggle(_ todo: Todo) {
        guard let index = todos.firstIndex(where: { $0.id == todo.id }) else { return }
        todos[index].isCompleted.toggle()
    }

    func delete(_ todo: Todo) {
        todos.removeAll { $0.id == todo.id }
    }

    func update(_ todo: Todo) {
        guard let index = todos.firstIndex(where: { $0.id == todo.id }) else { return }
        todos[index] = todo
    }
}
