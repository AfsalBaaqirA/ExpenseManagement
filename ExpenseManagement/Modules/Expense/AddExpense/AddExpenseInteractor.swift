//
//  AddExpenseInteractor.swift
//  ExpenseManagement
//
//  Created by Afsal Baaqir A on 20/02/26.
//

import Foundation
import CoreData

final class AddExpenseInteractor: AddExpenseInteractorInputProtocol {
    
    weak var presenter: AddExpenseInteractorOutputProtocol?
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext = CoreDataStack.shared.context) {
        self.context = context
    }
    
    func fetchCategories() {
        let fetchRequest: NSFetchRequest<Category> = Category.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        do {
            let categories = try context.fetch(fetchRequest)
            presenter?.didFetchCategories(categories)
        } catch {
            presenter?.didFailToFetchCategories(error)
        }
    }
    
    func createExpense(amount: Decimal, date: Date, category: Category, note: String?, paymentMethod: PaymentMethod) {
        let expense = Expense(context: context)
        expense.user = getUser()
        expense.id = UUID()
        expense.amount = amount as NSDecimalNumber
        expense.date = date
        expense.createdAt = Date()
        expense.updatedAt = Date()
        expense.category = category
        expense.note = note
        expense.paymentMethod = paymentMethod == .unspecified ? nil : paymentMethod.rawValue
        
        do {
            try context.save()
            presenter?.didCreateExpense(expense)
        } catch {
            presenter?.didFailToCreateExpense(error)
        }
    }
    
    func updateExpense(_ expense: Expense, amount: Decimal, date: Date, category: Category, note: String?, paymentMethod: PaymentMethod) {
        expense.amount = amount as NSDecimalNumber
        expense.date = date
        expense.updatedAt = Date()
        expense.category = category
        expense.note = note
        expense.paymentMethod = paymentMethod == .unspecified ? nil : paymentMethod.rawValue
        
        do {
            try context.save()
            presenter?.didUpdateExpense(expense)
        } catch {
            presenter?.didFailToUpdateExpense(error)
        }
    }
    
    private func getUser() -> User? {
        let userId = UserDefaults.standard.string(forKey: "userId")!
        let userFetch: NSFetchRequest<User> = User.fetchRequest()
        userFetch.predicate = NSPredicate(format: "id == %@", userId)
        guard let user = try? context.fetch(userFetch).first else {
            print("Failed to fetch user with id: \(userId)")
            return nil
        }
        return user
    }
}
