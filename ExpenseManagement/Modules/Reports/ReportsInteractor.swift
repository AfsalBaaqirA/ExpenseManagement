//
//  ReportsInteractor.swift
//  ExpenseManagement
//
//  Created by Afsal Baaqir A on 21/02/26.
//


import Foundation
import CoreData
import UIKit

final class ReportsInteractor: ReportsInteractorInputProtocol {
    weak var presenter: ReportsInteractorOutputProtocol?
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext = CoreDataStack.shared.context) {
        self.context = context
    }
    
    func fetchReport(for month: Date) {
        let calendar = Calendar.current
        guard let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: month)),
              let startOfNextMonth = calendar.date(byAdding: DateComponents(month: 1), to: startOfMonth),
              let startOfPreviousMonth = calendar.date(byAdding: DateComponents(month: -1), to: startOfMonth),
              let startOfPreviousMonthEnd = calendar.date(byAdding: DateComponents(month: 1), to: startOfPreviousMonth) else {
            return
        }
        
        // Current month expenses
        let currentRequest: NSFetchRequest<Expense> = Expense.fetchRequest()
        currentRequest.predicate = NSPredicate(format: "date >= %@ AND date < %@", startOfMonth as NSDate, startOfNextMonth as NSDate)
        
        // Previous month total
        let previousRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Expense")
        previousRequest.resultType = .dictionaryResultType
        previousRequest.propertiesToFetch = ["amount"]
        previousRequest.predicate = NSPredicate(format: "date >= %@ AND date < %@", startOfPreviousMonth as NSDate, startOfPreviousMonthEnd as NSDate)
        
        do {
            let expenses = try context.fetch(currentRequest)
            let grouped = Dictionary(grouping: expenses) { (expense: Expense) -> Category? in
                return expense.category
            }
            
            var categoryReports: [CategoryReportData] = []
            var total: Double = 0
            
            for (category, items) in grouped {
                let sum = items.reduce(0) { $0 + $1.safeAmount }
                guard sum > 0 else { continue }
                total += sum
                
                let categoryId = category?.id
                let name = category?.safeName ?? "Unknown"
                let colorHex = category?.colorHex
                let iconName = category?.iconName
                
                let report = CategoryReportData(
                    categoryId: categoryId,
                    categoryName: name,
                    totalAmount: sum,
                    colorHex: colorHex,
                    iconName: iconName
                )
                categoryReports.append(report)
            }
            
            var previousTotal: Double? = nil
            if let dictResults = try context.fetch(previousRequest) as? [[String: Any]] {
                let sum = dictResults.reduce(0.0) { partial, dict in
                    if let decimal = dict["amount"] as? NSDecimalNumber {
                        return partial + decimal.doubleValue
                    }
                    return partial
                }
                previousTotal = sum
            }
            
            let monthlyReport = MonthlyReportData(
                monthStart: startOfMonth,
                categories: categoryReports,
                totalAmount: total,
                previousMonthTotalAmount: previousTotal
            )
            
            presenter?.didFetchReport(monthlyReport)
        } catch {
            presenter?.didFailToFetchReport(error: error)
        }
    }
}
