//
//  TodoAPIService.swift
//  TodoListTest
//

import Foundation

protocol TodoAPIServiceProtocol {
    func fetchTodos() async throws -> [Todo]
}

final class TodoAPIService: TodoAPIServiceProtocol {
    private static let endpoint = URL(string: "https://dummyjson.com/todos")!

    func fetchTodos() async throws -> [Todo] {
        let (data, _) = try await URLSession.shared.data(from: Self.endpoint)
        let response = try JSONDecoder().decode(TodoListResponse.self, from: data)
        return response.todos.map { Todo(dto: $0) }
    }
}
