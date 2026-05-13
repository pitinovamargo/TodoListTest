//
//  TodoStorageTests.swift
//  TodoListTestTests
//

import XCTest
@testable import TodoListTest

@MainActor
final class TodoStorageTests: XCTestCase {
    private var storage: TodoStorage!

    override func setUp() async throws {
        let stack = CoreDataStack(inMemory: true)
        storage = TodoStorage(stack: stack)
    }

    // MARK: - save (single)

    func test_save_persistsTodo() async throws {
        let todo = Todo(title: "Тест")

        try await storage.save(todo)
        let fetched = try await storage.fetchAll()

        XCTAssertEqual(fetched.count, 1)
        XCTAssertEqual(fetched[0].title, "Тест")
        XCTAssertEqual(fetched[0].id, todo.id)
    }

    func test_save_updatesExisting() async throws {
        let todo = Todo(title: "Original")
        try await storage.save(todo)

        var changed = todo
        changed.title = "Updated"
        try await storage.save(changed)

        let fetched = try await storage.fetchAll()
        XCTAssertEqual(fetched.count, 1)
        XCTAssertEqual(fetched[0].title, "Updated")
    }

    // MARK: - save (bulk)

    func test_saveBulk_insertsAll() async throws {
        let todos = [
            Todo(title: "First"),
            Todo(title: "Second"),
            Todo(title: "Third")
        ]

        try await storage.save(todos)

        let fetched = try await storage.fetchAll()
        XCTAssertEqual(fetched.count, 3)
    }

    // MARK: - delete

    func test_delete_removesById() async throws {
        let keep = Todo(title: "Keep")
        let remove = Todo(title: "Remove")
        try await storage.save([keep, remove])

        try await storage.delete(id: remove.id)

        let fetched = try await storage.fetchAll()
        XCTAssertEqual(fetched.count, 1)
        XCTAssertEqual(fetched[0].title, "Keep")
    }

    func test_delete_nonExistentId_doesNotCrash() async throws {
        try await storage.save(Todo(title: "Only one"))

        try await storage.delete(id: UUID())

        let fetched = try await storage.fetchAll()
        XCTAssertEqual(fetched.count, 1)
    }

    // MARK: - search

    func test_search_findsByTitle() async throws {
        try await storage.save([
            Todo(title: "Купить продукты"),
            Todo(title: "Позвонить маме"),
            Todo(title: "Сделать зарядку")
        ])

        let results = try await storage.search("мам")

        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results[0].title, "Позвонить маме")
    }

    func test_search_findsByDetails() async throws {
        try await storage.save([
            Todo(title: "Покупки", details: "хлеб и молоко"),
            Todo(title: "Дела", details: "врач, банк")
        ])

        let results = try await storage.search("молок")

        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results[0].title, "Покупки")
    }

    func test_search_isCaseInsensitive() async throws {
        try await storage.save(Todo(title: "ВАЖНОЕ"))

        let results = try await storage.search("важное")

        XCTAssertEqual(results.count, 1)
    }

    func test_search_emptyQuery_returnsAll() async throws {
        try await storage.save([
            Todo(title: "First"),
            Todo(title: "Second")
        ])

        let results = try await storage.search("")

        XCTAssertEqual(results.count, 2)
    }

    // MARK: - fetchAll sort

    func test_fetchAll_sortsByUpdatedAtDescending() async throws {
        let old = Todo(title: "Old", updatedAt: Date(timeIntervalSince1970: 1000))
        let new = Todo(title: "New", updatedAt: Date(timeIntervalSince1970: 2000))

        try await storage.save([old, new])

        let fetched = try await storage.fetchAll()

        XCTAssertEqual(fetched.map(\.title), ["New", "Old"])
    }
}
