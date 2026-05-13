//
//  CoreDataStack.swift
//  TodoListTest
//

import Foundation
import CoreData

final class CoreDataStack {
    private let container: NSPersistentContainer

    init(modelName: String = "TodoListTest", inMemory: Bool = false) {
        container = NSPersistentContainer(name: modelName)

        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores { _, error in
            if let error {
                fatalError("Не удалось загрузить базу: \(error)")
            }
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
    }

    func newBackgroundContext() -> NSManagedObjectContext {
        container.newBackgroundContext()
    }
}
