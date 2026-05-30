//
//  Util.swift
//  ExpenseManagement
//
//  Created by Afsal Baaqir A on 21/02/26.
//


import CoreData

final class Util {
    static func deleteAllData() {
        let context = CoreDataStack.shared.context
        let userFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        let expenseFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Expense")
        let categoryFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Category")
        let budgetFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Budget")
        let fetchRequests: [NSFetchRequest<NSFetchRequestResult>] = [userFetchRequest, expenseFetchRequest, categoryFetchRequest, budgetFetchRequest]

        for fetchRequest in fetchRequests {
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            deleteRequest.resultType = .resultTypeObjectIDs
            do {
                let result = try context.execute(deleteRequest) as? NSBatchDeleteResult
                if let objectIDs = result?.result as? [NSManagedObjectID], !objectIDs.isEmpty {
                    let changes: [AnyHashable: Any] = [NSDeletedObjectsKey: objectIDs]
                    NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [context])
                }
            } catch {
                print("Failed to batch delete for request: \(fetchRequest.entityName ?? "?") error: \(error)")
            }
        }
        
        UserDefaults.standard.removeObject(forKey: "userId")
        UserDefaults.standard.removeObject(forKey: "localAuthDisabledPermanently")
        UserDefaults.standard.removeObject(forKey: "localAuthEnabled")
        
    }
}
