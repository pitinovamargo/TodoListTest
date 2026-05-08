//
//  TodoListTestApp.swift
//  TodoListTest
//
//  Created by Margarita Pitinova on 08.05.26.
//

import SwiftUI
import CoreData

@main
struct TodoListTestApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
