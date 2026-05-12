//
//  TodoEditViewModel.swift
//  TodoListTest
//

import Foundation
import Combine

@MainActor
final class TodoEditViewModel: ObservableObject {
    @Published var title: String
    @Published var details: String

    private let originalTodo: Todo

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yy"
        return formatter
    }()

    var canSave: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var formattedDate: String {
        Self.dateFormatter.string(from: originalTodo.createdAt)
    }

    init(todo: Todo) {
        self.originalTodo = todo
        self.title = todo.title
        self.details = todo.details
    }

    func updatedTodo() -> Todo {
        Todo(
            id: originalTodo.id,
            title: title,
            details: details,
            createdAt: originalTodo.createdAt,
            isCompleted: originalTodo.isCompleted
        )
    }
}
