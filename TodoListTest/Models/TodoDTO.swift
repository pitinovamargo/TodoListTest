//
//  TodoDTO.swift
//  TodoListTest
//

import Foundation

struct TodoDTO: Decodable {
    let id: Int
    let todo: String
    let completed: Bool
    let userId: Int
}

struct TodoListResponse: Decodable {
    let todos: [TodoDTO]
}

extension Todo {
    init(dto: TodoDTO) {
        self.init(
            title: dto.todo,
            details: "",
            isCompleted: dto.completed
        )
    }
}
