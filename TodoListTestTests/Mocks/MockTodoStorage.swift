//
//  MockTodoStorage.swift
//  TodoListTestTests
//

import Foundation
@testable import TodoListTest

final class MockTodoStorage: TodoStorageProtocol {
    var storedTodos: [Todo] = []

    var fetchAllCallCount = 0
    var saveSingleCallCount = 0
    var saveBulkCallCount = 0
    var deleteCallCount = 0
    var searchCallCount = 0

    var errorToThrow: Error?

    func fetchAll() async throws -> [Todo] {
        fetchAllCallCount += 1
        if let errorToThrow { throw errorToThrow }
        return storedTodos
    }

    func save(_ todo: Todo) async throws {
        saveSingleCallCount += 1
        if let errorToThrow { throw errorToThrow }
        upsert(todo)
    }

    func save(_ todos: [Todo]) async throws {
        saveBulkCallCount += 1
        if let errorToThrow { throw errorToThrow }
        for todo in todos {
            upsert(todo)
        }
    }

    func delete(id: UUID) async throws {
        deleteCallCount += 1
        if let errorToThrow { throw errorToThrow }
        storedTodos.removeAll { $0.id == id }
    }

    func search(_ query: String) async throws -> [Todo] {
        searchCallCount += 1
        if let errorToThrow { throw errorToThrow }
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if trimmed.isEmpty { return storedTodos }
        return storedTodos.filter { todo in
            todo.title.lowercased().contains(trimmed)
                || todo.details.lowercased().contains(trimmed)
        }
    }

    private func upsert(_ todo: Todo) {
        if let index = storedTodos.firstIndex(where: { $0.id == todo.id }) {
            storedTodos[index] = todo
        } else {
            storedTodos.append(todo)
        }
    }
}
