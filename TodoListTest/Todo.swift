//
//  Todo.swift
//  TodoListTest
//

import Foundation

struct Todo: Identifiable, Hashable {
    let id: UUID
    var title: String
    var details: String
    var createdAt: Date
    var isCompleted: Bool

    init(
        id: UUID = UUID(),
        title: String,
        details: String = "",
        createdAt: Date = Date(),
        isCompleted: Bool = false
    ) {
        self.id = id
        self.title = title
        self.details = details
        self.createdAt = createdAt
        self.isCompleted = isCompleted
    }
}

extension Todo {
    static let sampleData: [Todo] = [
        Todo(
            title: "Купить продукты",
            details: "Молоко, хлеб, яйца, кофе",
            createdAt: Date().addingTimeInterval(-3600 * 24 * 2)
        ),
        Todo(
            title: "Записаться к врачу",
            details: "Терапевт, поликлиника на Ленина",
            createdAt: Date().addingTimeInterval(-3600 * 24),
            isCompleted: true
        ),
        Todo(
            title: "Сделать зарядку",
            details: "20 минут утром",
            createdAt: Date().addingTimeInterval(-3600 * 5)
        ),
        Todo(
            title: "Прочитать главу книги",
            details: "Кнут, том 1, глава 2",
            createdAt: Date().addingTimeInterval(-3600 * 3)
        ),
        Todo(
            title: "Позвонить маме",
            details: "",
            createdAt: Date().addingTimeInterval(-3600),
            isCompleted: true
        ),
        Todo(
            title: "Доделать тестовое задание",
            details: "TodoList с CoreData и API",
            createdAt: Date()
        )
    ]
}
