//
//  TodoStorage.swift
//  TodoListTest
//

import Foundation
import CoreData

protocol TodoStorageProtocol {
    func fetchAll() async throws -> [Todo]
    func save(_ todo: Todo) async throws
    func save(_ todos: [Todo]) async throws
    func delete(id: UUID) async throws
    func search(_ query: String) async throws -> [Todo]
}

final class TodoStorage: TodoStorageProtocol {
    private let stack: CoreDataStack

    init(stack: CoreDataStack) {
        self.stack = stack
    }

    func fetchAll() async throws -> [Todo] {
        let context = stack.newBackgroundContext()
        return try await context.perform {
            let request = TodoEntity.fetchRequest()
            request.sortDescriptors = [
                NSSortDescriptor(keyPath: \TodoEntity.updatedAt, ascending: false)
            ]
            let entities = try context.fetch(request)
            return entities.map { Todo(entity: $0) }
        }
    }

    func save(_ todo: Todo) async throws {
        let context = stack.newBackgroundContext()
        try await context.perform {
            let request = TodoEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", todo.id as CVarArg)
            request.fetchLimit = 1

            let entity = try context.fetch(request).first ?? TodoEntity(context: context)
            entity.apply(todo)
            try context.save()
        }
    }

    func save(_ todos: [Todo]) async throws {
        let context = stack.newBackgroundContext()
        try await context.perform {
            for todo in todos {
                let request = TodoEntity.fetchRequest()
                request.predicate = NSPredicate(format: "id == %@", todo.id as CVarArg)
                request.fetchLimit = 1

                let entity = try context.fetch(request).first ?? TodoEntity(context: context)
                entity.apply(todo)
            }
            try context.save()
        }
    }

    func delete(id: UUID) async throws {
        let context = stack.newBackgroundContext()
        try await context.perform {
            let request = TodoEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            let entities = try context.fetch(request)
            for entity in entities {
                context.delete(entity)
            }
            try context.save()
        }
    }

    func search(_ query: String) async throws -> [Todo] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            return try await fetchAll()
        }

        let context = stack.newBackgroundContext()
        return try await context.perform {
            let request = TodoEntity.fetchRequest()
            request.predicate = NSPredicate(
                format: "title CONTAINS[cd] %@ OR details CONTAINS[cd] %@",
                trimmed, trimmed
            )
            request.sortDescriptors = [
                NSSortDescriptor(keyPath: \TodoEntity.updatedAt, ascending: false)
            ]
            let entities = try context.fetch(request)
            return entities.map { Todo(entity: $0) }
        }
    }
}
