//
//  InitialLoadFlag.swift
//  TodoListTest
//

import Foundation

final class InitialLoadFlag {
    private static let key = "didLoadInitial"
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    var isSet: Bool {
        defaults.bool(forKey: Self.key)
    }

    func set() {
        defaults.set(true, forKey: Self.key)
    }
}
