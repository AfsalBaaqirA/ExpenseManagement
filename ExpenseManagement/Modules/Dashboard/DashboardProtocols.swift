//
//  DashboardProtocols.swift
//  ExpenseManagement
//
//  Created by Afsal Baaqir A on 14/02/26.
//


import UIKit
import CoreData

// MARK: - View Protocol
protocol DashboardViewProtocol: AnyObject {
    var presenter: DashboardPresenterProtocol? { get set }
    
    func showExpenses(_ expenses: [Expense])
    func updateSummary(income: String, expenses: String, savings: String)
    func showError(_ message: String)
    func askToPopulateSampleData()
}

// MARK: - Presenter Protocol
protocol DashboardPresenterProtocol: AnyObject {
    var view: DashboardViewProtocol? { get set }
    var interactor: DashboardInteractorInputProtocol? { get set }
    var router: DashboardRouterProtocol? { get set }
    
    func viewDidLoad()
    func refreshData()
    func didSelectSeeAll()
    
    func didUpdateIncome(_ income: Double)
    func didConfirmPopulateSampleData()
}

// MARK: - Interactor Input Protocol
protocol DashboardInteractorInputProtocol: AnyObject {
    var presenter: DashboardInteractorOutputProtocol? { get set }
    
    func fetchExpenses()
    func generateSampleDataIfNeeded()
    func populateSampleData()
    
    func updateIncome(_ income: Double)
}

// MARK: - Interactor Output Protocol
protocol DashboardInteractorOutputProtocol: AnyObject {
    func didFetchExpenses(_ expenses: [Expense], incomeAmount: Double)
    func didFailToFetchExpenses(with error: Error)
    func shouldAskToPopulateSampleData()
}

// MARK: - Router Protocol
protocol DashboardRouterProtocol: AnyObject {
    static func createModule() -> UIViewController
    func navigateToAllExpenses()
}
