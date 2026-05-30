//
//  CoreDataStack.swift
//  ExpenseManagement
//
//  Created by Afsal Baaqir A on 14/02/26.
//


import CoreData

class CoreDataStack {
    static let shared = CoreDataStack()
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "ExpenseManagement")
        container.loadPersistentStores { _, error in
            if let error = error as NSError? { fatalError("Unresolved error \(error)") }
        }
        return container
    }()

    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    func saveContext() {
        if context.hasChanges {
            try? context.save()
        }
    }
}
