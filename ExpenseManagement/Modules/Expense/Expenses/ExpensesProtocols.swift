//
//  ExpensesProtocols.swift
//  ExpenseManagement
//
//  Created by Afsal Baaqir A on 19/02/26.
//

import UIKit
import CoreData

// MARK: - View Protocol
protocol ExpensesViewProtocol: AnyObject {
    var presenter: ExpensesPresenterProtocol? { get set }
    
    func showExpenses(_ expenses: [Expense])
    func showError(_ message: String)
    func showLoading()
    func hideLoading()
    func didDeleteExpense(_ expense: Expense)
    func updateFilterState(categoryName: String?, categoryColor: UIColor?)
}

// MARK: - Presenter Protocol
protocol ExpensesPresenterProtocol: AnyObject {
    var view: ExpensesViewProtocol? { get set }
    var interactor: ExpensesInteractorInputProtocol? { get set }
    var router: ExpensesRouterProtocol? { get set }
    
    func viewDidLoad()
    func refreshData()
    func didSelectAddExpense()
    func didSelectEditExpense(_ expense: Expense)
    func didRequestDeleteExpense(_ expense: Expense)
    func didTapFilterButton(from viewController: UIViewController, anchor: UIBarButtonItem?)
}

// MARK: - Interactor Input Protocol
protocol ExpensesInteractorInputProtocol: AnyObject {
    var presenter: ExpensesInteractorOutputProtocol? { get set }
    
    func fetchAllExpenses()
    func deleteExpense(_ expense: Expense)
}

// MARK: - Interactor Output Protocol
protocol ExpensesInteractorOutputProtocol: AnyObject {
    func didFetchExpenses(_ expenses: [Expense])
    func didFailToFetchExpenses(with error: Error)
    func didDeleteExpense(_ expense: Expense)
    func didFailToDeleteExpense(_ error: Error)
}

// MARK: - Router Protocol
protocol ExpensesRouterProtocol: AnyObject {
    static func createModule() -> UINavigationController
    func navigateToAddExpense(from view: ExpensesViewProtocol?, delegate: AddExpenseModuleDelegate)
    func navigateToEditExpense(from view: ExpensesViewProtocol?, expense: Expense, delegate: AddExpenseModuleDelegate)
}
