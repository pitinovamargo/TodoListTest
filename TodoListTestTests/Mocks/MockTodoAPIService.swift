//
//  MockTodoAPIService.swift
//  TodoListTestTests
//

import Foundation
@testable import TodoListTest

final class MockTodoAPIService: TodoAPIServiceProtocol {
    var todosToReturn: [Todo] = []
    var fetchCallCount = 0
    var errorToThrow: Error?

    func fetchTodos() async throws -> [Todo] {
        fetchCallCount += 1
        if let errorToThrow { throw errorToThrow }
        return todosToReturn
    }
}
