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
    private let api: TodoAPIServiceProtocol = TodoAPIService()
    private let initialLoadFlag = InitialLoadFlag()

    var body: some Scene {
        WindowGroup {
            TodoListView(
                storage: storage,
                api: api,
                initialLoadFlag: initialLoadFlag
            )
            .preferredColorScheme(.dark)
        }
    }
}
