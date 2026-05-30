//
//  ExpensesInteractor.swift
//  ExpenseManagement
//
//  Created by Afsal Baaqir A on 19/02/26.
//

import Foundation
import CoreData

final class ExpensesInteractor: ExpensesInteractorInputProtocol {
    
    weak var presenter: ExpensesInteractorOutputProtocol?
    
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext = CoreDataStack.shared.context) {
        self.context = context
    }
    
    func fetchAllExpenses() {
        let fetchRequest: NSFetchRequest<Expense> = Expense.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        do {
            let expenses = try context.fetch(fetchRequest)
            presenter?.didFetchExpenses(expenses)
        } catch {
            presenter?.didFailToFetchExpenses(with: error)
        }
    }
    
    func deleteExpense(_ expense: Expense) {
        context.delete(expense)
        do {
            try context.save()
            presenter?.didDeleteExpense(expense)
        } catch {
            presenter?.didFailToDeleteExpense(error)
        }
    }
}
