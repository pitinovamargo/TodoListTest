//
//  InitialLoadFlagTests.swift
//  TodoListTestTests
//

import XCTest
@testable import TodoListTest

@MainActor
final class InitialLoadFlagTests: XCTestCase {
    private var defaults: UserDefaults!
    private var suiteName: String!

    override func setUp() {
        suiteName = UUID().uuidString
        defaults = UserDefaults(suiteName: suiteName)!
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: suiteName)
    }

    func test_isSet_initiallyFalse() {
        let flag = InitialLoadFlag(defaults: defaults)

        XCTAssertFalse(flag.isSet)
    }

    func test_set_makesIsSetTrue() {
        let flag = InitialLoadFlag(defaults: defaults)
        flag.set()

        XCTAssertTrue(flag.isSet)
    }

    func test_set_persistsAcrossInstances() {
        let firstInstance = InitialLoadFlag(defaults: defaults)
        firstInstance.set()

        let secondInstance = InitialLoadFlag(defaults: defaults)
        XCTAssertTrue(secondInstance.isSet)
    }
}
