//
//  TodoEditViewModelTests.swift
//  TodoListTestTests
//

import XCTest
@testable import TodoListTest

@MainActor
final class TodoEditViewModelTests: XCTestCase {

    // MARK: - init

    func test_init_populatesFieldsFromTodo() {
        let todo = Todo(title: "Заголовок", details: "Описание")
        let viewModel = TodoEditViewModel(todo: todo)

        XCTAssertEqual(viewModel.title, "Заголовок")
        XCTAssertEqual(viewModel.details, "Описание")
    }

    // MARK: - canSave

    func test_canSave_falseWhenTitleEmpty() {
        let viewModel = TodoEditViewModel(todo: Todo(title: ""))

        XCTAssertFalse(viewModel.canSave)
    }

    func test_canSave_falseWhenTitleIsOnlyWhitespace() {
        let viewModel = TodoEditViewModel(todo: Todo(title: ""))
        viewModel.title = "   \n  "

        XCTAssertFalse(viewModel.canSave)
    }

    func test_canSave_trueWhenTitleHasContent() {
        let viewModel = TodoEditViewModel(todo: Todo(title: ""))
        viewModel.title = "Привет"

        XCTAssertTrue(viewModel.canSave)
    }

    // MARK: - hasChanges

    func test_hasChanges_falseInitially() {
        let viewModel = TodoEditViewModel(todo: Todo(title: "X", details: "Y"))

        XCTAssertFalse(viewModel.hasChanges)
    }

    func test_hasChanges_trueAfterTitleChange() {
        let viewModel = TodoEditViewModel(todo: Todo(title: "Old"))
        viewModel.title = "New"

        XCTAssertTrue(viewModel.hasChanges)
    }

    func test_hasChanges_trueAfterDetailsChange() {
        let viewModel = TodoEditViewModel(todo: Todo(title: "X", details: "Old"))
        viewModel.details = "New"

        XCTAssertTrue(viewModel.hasChanges)
    }

    func test_hasChanges_falseWhenChangedAndRevertedBack() {
        let viewModel = TodoEditViewModel(todo: Todo(title: "Original"))
        viewModel.title = "Changed"
        viewModel.title = "Original"

        XCTAssertFalse(viewModel.hasChanges)
    }

    // MARK: - updatedTodo

    func test_updatedTodo_preservesIdCreatedAtAndIsCompleted() {
        let createdAt = Date(timeIntervalSince1970: 1000)
        let original = Todo(
            id: UUID(),
            title: "Old",
            details: "Old",
            createdAt: createdAt,
            updatedAt: createdAt,
            isCompleted: true
        )
        let viewModel = TodoEditViewModel(todo: original)
        viewModel.title = "New"
        viewModel.details = "Now"

        let result = viewModel.updatedTodo()

        XCTAssertEqual(result.id, original.id)
        XCTAssertEqual(result.createdAt, createdAt)
        XCTAssertTrue(result.isCompleted)
        XCTAssertEqual(result.title, "New")
        XCTAssertEqual(result.details, "Now")
    }
}
