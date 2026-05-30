//
//  AddExpenseProtocols.swift
//  ExpenseManagement
//
//  Created by Afsal Baaqir A on 20/02/26.
//

import UIKit
import CoreData

// MARK: - View Protocol
protocol AddExpenseViewProtocol: AnyObject {
    var presenter: AddExpensePresenterProtocol? { get set }
    
    func showValidationError(_ message: String)
    func showSaving()
    func hideSaving()
    func dismiss()
    func showMode(isEditing: Bool)
    func configureInitialState(categories: [Category])
    func configurePaymentMethods(_ methods: [PaymentMethod])
    func setSelected(paymentMethod: PaymentMethod)
    func populateFields(with expense: Expense)
}

// MARK: - Presenter Protocol
protocol AddExpensePresenterProtocol: AnyObject {
    var view: AddExpenseViewProtocol? { get set }
    var interactor: AddExpenseInteractorInputProtocol? { get set }
    var router: AddExpenseRouterProtocol? { get set }
    var delegate: AddExpenseModuleDelegate? { get set }
    
    func viewDidLoad()
    func didTapCancel()
    func didTapSave(amountText: String?, date: Date, categoryIndex: Int, note: String?, paymentMethodIndex: Int)
    func configureForNewExpense()
    func configureForEditing(expense: Expense)
}

// MARK: - Interactor Input Protocol
protocol AddExpenseInteractorInputProtocol: AnyObject {
    var presenter: AddExpenseInteractorOutputProtocol? { get set }

    func fetchCategories()
    func createExpense(amount: Decimal, date: Date, category: Category, note: String?, paymentMethod: PaymentMethod)
    func updateExpense(_ expense: Expense, amount: Decimal, date: Date, category: Category, note: String?, paymentMethod: PaymentMethod)
}

// MARK: - Interactor Output Protocol
protocol AddExpenseInteractorOutputProtocol: AnyObject {
    func didFetchCategories(_ categories: [Category])
    func didFailToFetchCategories(_ error: Error)
    func didCreateExpense(_ expense: Expense)
    func didFailToCreateExpense(_ error: Error)
    func didUpdateExpense(_ expense: Expense)
    func didFailToUpdateExpense(_ error: Error)
}

// MARK: - Router Protocol
protocol AddExpenseRouterProtocol: AnyObject {
    static func createModule(delegate: AddExpenseModuleDelegate?) -> UIViewController
    func dismiss(view: AddExpenseViewProtocol?)
}

// MARK: - Module Delegate
protocol AddExpenseModuleDelegate: AnyObject {
    func addExpenseModuleDidCreateExpense(_ expense: Expense)
    func addExpenseModuleDidUpdateExpense(_ expense: Expense)
}
