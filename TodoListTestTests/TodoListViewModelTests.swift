//
//  TodoListViewModelTests.swift
//  TodoListTestTests
//

import XCTest
@testable import TodoListTest

@MainActor
final class TodoListViewModelTests: XCTestCase {
    private var storage: MockTodoStorage!
    private var api: MockTodoAPIService!
    private var flag: InitialLoadFlag!
    private var defaults: UserDefaults!
    private var suiteName: String!

    override func setUp() async throws {
        suiteName = UUID().uuidString
        defaults = UserDefaults(suiteName: suiteName)!
        storage = MockTodoStorage()
        api = MockTodoAPIService()
        flag = InitialLoadFlag(defaults: defaults)
    }

    override func tearDown() async throws {
        defaults.removePersistentDomain(forName: suiteName)
    }

    private func makeViewModel() -> TodoListViewModel {
        TodoListViewModel(storage: storage, api: api, initialLoadFlag: flag)
    }

    private func waitForBackgroundTasks() async {
        for _ in 0..<10 { await Task.yield() }
    }

    // MARK: - load()

    func test_load_firstLaunch_importsFromAPIAndSetsFlag() async {
        api.todosToReturn = [Todo(title: "First"), Todo(title: "Second")]

        let viewModel = makeViewModel()
        await viewModel.load()

        XCTAssertEqual(api.fetchCallCount, 1)
        XCTAssertEqual(storage.saveBulkCallCount, 1)
        XCTAssertTrue(flag.isSet)
        XCTAssertEqual(viewModel.todos.count, 2)
    }

    func test_load_subsequentLaunch_doesNotCallAPI() async {
        flag.set()
        storage.storedTodos = [Todo(title: "Local")]

        let viewModel = makeViewModel()
        await viewModel.load()

        XCTAssertEqual(api.fetchCallCount, 0)
        XCTAssertEqual(storage.fetchAllCallCount, 1)
        XCTAssertEqual(viewModel.todos.count, 1)
    }

    func test_load_whenAPIFails_doesNotSetFlag() async {
        api.errorToThrow = URLError(.notConnectedToInternet)

        let viewModel = makeViewModel()
        await viewModel.load()

        XCTAssertEqual(api.fetchCallCount, 1)
        XCTAssertFalse(flag.isSet)
        XCTAssertTrue(viewModel.todos.isEmpty)
    }

    // MARK: - toggle

    func test_toggle_changesInMemoryState() async {
        let todo = Todo(title: "Test")
        storage.storedTodos = [todo]
        flag.set()

        let viewModel = makeViewModel()
        await viewModel.load()
        viewModel.toggle(todo)

        XCTAssertTrue(viewModel.todos[0].isCompleted)
    }

    func test_toggle_persistsToStorage() async {
        let todo = Todo(title: "Test")
        storage.storedTodos = [todo]
        flag.set()

        let viewModel = makeViewModel()
        await viewModel.load()
        viewModel.toggle(todo)
        await waitForBackgroundTasks()

        XCTAssertEqual(storage.saveSingleCallCount, 1)
    }

    func test_toggle_doesNotBumpUpdatedAt() async {
        let originalDate = Date(timeIntervalSince1970: 1000)
        let todo = Todo(title: "Test", createdAt: originalDate, updatedAt: originalDate)
        storage.storedTodos = [todo]
        flag.set()

        let viewModel = makeViewModel()
        await viewModel.load()
        viewModel.toggle(todo)

        XCTAssertEqual(viewModel.todos[0].updatedAt, originalDate)
    }

    // MARK: - save

    func test_save_existing_updatesAndBumpsUpdatedAt() async {
        let oldDate = Date(timeIntervalSince1970: 1000)
        let original = Todo(title: "Old", createdAt: oldDate, updatedAt: oldDate)
        storage.storedTodos = [original]
        flag.set()

        let viewModel = makeViewModel()
        await viewModel.load()

        var changed = original
        changed.title = "New"
        viewModel.save(changed)

        XCTAssertEqual(viewModel.todos[0].title, "New")
        XCTAssertGreaterThan(viewModel.todos[0].updatedAt, oldDate)
    }

    func test_save_new_appendsToList() async {
        flag.set()
        let viewModel = makeViewModel()
        await viewModel.load()

        viewModel.save(Todo(title: "Fresh"))

        XCTAssertEqual(viewModel.todos.count, 1)
        XCTAssertEqual(viewModel.todos[0].title, "Fresh")
    }

    // MARK: - delete

    func test_delete_removesFromMemoryAndCallsStorage() async {
        let todo = Todo(title: "Doomed")
        storage.storedTodos = [todo]
        flag.set()

        let viewModel = makeViewModel()
        await viewModel.load()
        viewModel.delete(todo)
        await waitForBackgroundTasks()

        XCTAssertTrue(viewModel.todos.isEmpty)
        XCTAssertEqual(storage.deleteCallCount, 1)
    }

    // MARK: - displayedTodos

    func test_displayedTodos_filtersBySearchQuery() async {
        storage.storedTodos = [
            Todo(title: "Купить продукты", details: "хлеб и молоко"),
            Todo(title: "Позвонить маме"),
            Todo(title: "Сделать зарядку")
        ]
        flag.set()

        let viewModel = makeViewModel()
        await viewModel.load()
        viewModel.searchQuery = "мам"

        XCTAssertEqual(viewModel.displayedTodos.count, 1)
        XCTAssertEqual(viewModel.displayedTodos[0].title, "Позвонить маме")
    }

    func test_displayedTodos_searchIsCaseInsensitive() async {
        storage.storedTodos = [Todo(title: "Купить ПРОДУКТЫ")]
        flag.set()

        let viewModel = makeViewModel()
        await viewModel.load()
        viewModel.searchQuery = "продукты"

        XCTAssertEqual(viewModel.displayedTodos.count, 1)
    }

    func test_displayedTodos_searchMatchesDetails() async {
        storage.storedTodos = [
            Todo(title: "Покупки", details: "молоко"),
            Todo(title: "Звонок", details: "врач")
        ]
        flag.set()

        let viewModel = makeViewModel()
        await viewModel.load()
        viewModel.searchQuery = "врач"

        XCTAssertEqual(viewModel.displayedTodos.count, 1)
        XCTAssertEqual(viewModel.displayedTodos[0].title, "Звонок")
    }

    func test_displayedTodos_sortsByUpdatedAtDescending() async {
        storage.storedTodos = [
            Todo(title: "Old", updatedAt: Date(timeIntervalSince1970: 1000)),
            Todo(title: "New", updatedAt: Date(timeIntervalSince1970: 3000)),
            Todo(title: "Middle", updatedAt: Date(timeIntervalSince1970: 2000))
        ]
        flag.set()

        let viewModel = makeViewModel()
        await viewModel.load()

        XCTAssertEqual(viewModel.displayedTodos.map(\.title), ["New", "Middle", "Old"])
    }

    // MARK: - startNewTodo

    func test_startNewTodo_appendsEmptyTodoToPath() {
        let viewModel = makeViewModel()

        XCTAssertTrue(viewModel.path.isEmpty)
        viewModel.startNewTodo()

        XCTAssertEqual(viewModel.path.count, 1)
        XCTAssertEqual(viewModel.path[0].title, "")
    }
}
