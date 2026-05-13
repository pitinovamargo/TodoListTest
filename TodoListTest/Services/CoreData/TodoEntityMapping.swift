//
//  TodoEntityMapping.swift
//  TodoListTest
//

import Foundation
import CoreData

extension Todo {
    init(entity: TodoEntity) {
        self.init(
            id: entity.id ?? UUID(),
            title: entity.title ?? "",
            details: entity.details ?? "",
            createdAt: entity.createdAt ?? Date(),
            updatedAt: entity.updatedAt ?? Date(),
            isCompleted: entity.isCompleted
        )
    }
}

extension TodoEntity {
    func apply(_ todo: Todo) {
        id = todo.id
        title = todo.title
        details = todo.details
        createdAt = todo.createdAt
        updatedAt = todo.updatedAt
        isCompleted = todo.isCompleted
    }
}
