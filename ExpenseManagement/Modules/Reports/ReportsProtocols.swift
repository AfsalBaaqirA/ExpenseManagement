//
//  ReportsViewProtocol.swift
//  ExpenseManagement
//
//  Created by Afsal Baaqir A on 21/02/26.
//


import Foundation
import UIKit

protocol ReportsViewProtocol: AnyObject {
    func updateMonth(title: String, date: Date, isPreviousEnabled: Bool, isNextEnabled: Bool)
    func updateReport(slices: [ReportCategorySliceViewData], totalText: String)
    func showEmptyState(message: String)
    func updateHeroCard(monthTitle: String, totalText: String, changeText: String?, changeColor: UIColor?)
}

protocol ReportsPresenterProtocol: AnyObject {
    func viewDidLoad()
    func didTapPreviousMonth()
    func didTapNextMonth()
}

protocol ReportsInteractorInputProtocol: AnyObject {
    func fetchReport(for month: Date)
}

protocol ReportsInteractorOutputProtocol: AnyObject {
    func didFetchReport(_ report: MonthlyReportData)
    func didFailToFetchReport(error: Error)
}

protocol ReportsRouterProtocol: AnyObject {
    static func createModule() -> UIViewController
}

struct CategoryReportData {
    let categoryId: UUID?
    let categoryName: String
    let totalAmount: Double
    let colorHex: String?
    let iconName: String?
}

struct MonthlyReportData {
    let monthStart: Date
    let categories: [CategoryReportData]
    let totalAmount: Double
    let previousMonthTotalAmount: Double?
}

struct ReportCategorySliceViewData {
    let categoryName: String
    let amount: Double
    let amountText: String
    let percentageText: String
    let color: UIColor
}
