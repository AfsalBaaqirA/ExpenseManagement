//
//  DashboardInteractor.swift
//  ExpenseManagement
//
//  Created by Afsal Baaqir A on 14/02/26.
//


import Foundation
import CoreData
import UIKit

final class DashboardInteractor: DashboardInteractorInputProtocol {
    weak var presenter: DashboardInteractorOutputProtocol?
    
    func fetchExpenses() {
        let context = CoreDataStack.shared.context
        let userId = UserDefaults.standard.string(forKey: "userId")!
        
        // Fetch expenses for the current user
        let expenseFetchRequest: NSFetchRequest<Expense> = Expense.fetchRequest()
        expenseFetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        expenseFetchRequest.predicate = NSPredicate(format: "user.id == %@", userId)
        
        do {
            let expenses = try context.fetch(expenseFetchRequest)
            let user = getUser()
            
            var incomeAmount: Double = 0
            if let user = user {
                if let decimalIncome = user.value(forKey: "income") as? NSDecimalNumber {
                    incomeAmount = decimalIncome.doubleValue
                }
            }
            
            presenter?.didFetchExpenses(expenses, incomeAmount: incomeAmount)
        } catch {
            presenter?.didFailToFetchExpenses(with: error)
        }
    }
    
    func generateSampleDataIfNeeded() {
        let context = CoreDataStack.shared.context
        
        let fetchRequest: NSFetchRequest<Expense> = Expense.fetchRequest()
        fetchRequest.fetchLimit = 1
        
        do {
            let count = try context.count(for: fetchRequest)
            if count == 0 {
                presenter?.shouldAskToPopulateSampleData()
            }
        } catch {
            print("Failed to count expenses: \(error)")
            return
        }
    }
    
    func populateSampleData() {
        let context = CoreDataStack.shared.context
        populateSampleData(context: context)
    }
    
    private func populateSampleData(context: NSManagedObjectContext) {
        let categoriesData: [(name: String, icon: String, color: UIColor)] = [
            ("Food", "fork.knife", .systemOrange),
            ("Transport", "car.fill", .systemBlue),
            ("Shopping", "cart.fill", .systemPink),
            ("Entertainment", "tv.fill", .systemPurple),
            ("Bills", "doc.text.fill", .systemRed),
            ("Health", "heart.fill", .systemGreen),
            ("Education", "book.fill", .systemIndigo),
            ("Travel", "airplane", .systemTeal)
        ]
        
        var categories: [Category] = []
        for categoryData in categoriesData {
            let category = Category(context: context)
            category.id = UUID()
            category.name = categoryData.name
            category.iconName = categoryData.icon
            category.colorHex = categoryData.color.toHex()
            categories.append(category)
        }
        
        let user = getUser()
        let income = NSDecimalNumber(value: Double.random(in: 7000...15000))
        if let user = user {
            user.setValue(income, forKey: "income")
        }
        
        // Create sample expenses
        let notes = [
            "Lunch at restaurant",
            "Uber ride",
            "Grocery shopping",
            "Movie tickets",
            "Electricity bill",
            "Gym membership",
            "Online course",
            "Weekend trip",
            "Coffee",
            "Gas station",
            "Clothing store",
            "Concert tickets",
            "Internet bill",
            "Doctor visit",
            "Books",
            "Hotel booking"
        ]
        
        for _ in 0..<15 {
            let expense = Expense(context: context)
            expense.id = UUID()
            expense.amount = NSDecimalNumber(value: Double.random(in: 5...500))
            
            let daysAgo = Int.random(in: 0...30)
            expense.date = Calendar.current.date(byAdding: .day, value: -daysAgo, to: Date())
            expense.createdAt = Date()
            expense.updatedAt = Date()
            
            expense.note = notes.randomElement()
            expense.paymentMethod = PaymentMethod.allCases.randomElement()?.rawValue
            
            expense.category = categories.randomElement()
            expense.user = user
        }
        
        do {
            try context.save()
            print("Sample data created successfully")
        } catch {
            print("Failed to save sample data: \(error)")
        }
    }
    
    private func getUser() -> User? {
        let context = CoreDataStack.shared.context
        let userId = UserDefaults.standard.string(forKey: "userId")!
        let userFetch: NSFetchRequest<User> = User.fetchRequest()
        userFetch.predicate = NSPredicate(format: "id == %@", userId)
        guard let user = try? context.fetch(userFetch).first else {
            print("Failed to fetch user with id: \(userId)")
            return nil
        }
        return user
    }
    
    func updateIncome(_ income: Double) {
        let context = CoreDataStack.shared.context
        guard let user = getUser() else { return }
        
        user.setValue(NSDecimalNumber(value: income), forKey: "income")
        
        do {
            try context.save()
            fetchExpenses()
        } catch {
            presenter?.didFailToFetchExpenses(with: error)
        }
    }
}
