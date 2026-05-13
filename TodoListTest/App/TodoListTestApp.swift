//
//  TodoListTestApp.swift
//  TodoListTest
//
//  Created by Margarita Pitinova on 08.05.26.
//

import SwiftUI

@main
struct TodoListTestApp: App {
    private let storage: TodoStorageProtocol = TodoStorage(stack: CoreDataStack())

    var body: some Scene {
        WindowGroup {
            TodoListView(storage: storage)
                .preferredColorScheme(.dark)
        }
    }
}
