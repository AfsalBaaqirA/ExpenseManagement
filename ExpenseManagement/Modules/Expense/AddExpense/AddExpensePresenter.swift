//
//  AddExpensePresenter.swift
//  ExpenseManagement
//
//  Created by Afsal Baaqir A on 20/02/26.
//

import Foundation

final class AddExpensePresenter: AddExpensePresenterProtocol {
    
    weak var view: AddExpenseViewProtocol?
    var interactor: AddExpenseInteractorInputProtocol?
    var router: AddExpenseRouterProtocol?
    weak var delegate: AddExpenseModuleDelegate?
    
    private var categories: [Category] = []
    private let paymentMethods: [PaymentMethod] = PaymentMethod.allCases.filter { $0 != .unspecified }
    
    private var isEditing: Bool = false
    private var editingExpense: Expense?
    
    func viewDidLoad() {
        interactor?.fetchCategories()
        view?.configurePaymentMethods(paymentMethods)
    }
    
    // MARK: - Configuration
    func configureForNewExpense() {
        isEditing = false
        editingExpense = nil
        view?.showMode(isEditing: false)
    }
    
    func configureForEditing(expense: Expense) {
        isEditing = true
        editingExpense = expense
        view?.showMode(isEditing: true)
        view?.populateFields(with: expense)
        view?.setSelected(paymentMethod: expense.paymentMethodEnum)
    }
    
    func didTapCancel() {
        router?.dismiss(view: view)
    }
    
    private func parseAmount(from text: String) -> Decimal? {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = .current
        
        if let number = formatter.number(from: trimmed) {
            return number.decimalValue
        }
        
        let normalized = trimmed.replacingOccurrences(of: ",", with: ".")
        return Decimal(string: normalized)
    }
    
    func didTapSave(amountText: String?, date: Date, categoryIndex: Int, note: String?, paymentMethodIndex: Int) {
        
        guard let rawAmountText = amountText,
              let amount = parseAmount(from: rawAmountText),
              amount > 0 else {
            view?.showValidationError("Please enter a valid amount.")
            return
        }
        
        guard !categories.isEmpty, categories.indices.contains(categoryIndex) else {
            view?.showValidationError("Please select a category.")
            return
        }
        
        guard paymentMethods.indices.contains(paymentMethodIndex) else {
            view?.showValidationError("Please select a payment method.")
            return
        }
        
        let selectedCategory = categories[categoryIndex]
        let selectedPaymentMethod = paymentMethods[paymentMethodIndex]
        view?.showSaving()
        
        if isEditing, let expense = editingExpense {
            interactor?.updateExpense(expense, amount: amount, date: date, category: selectedCategory, note: note, paymentMethod: selectedPaymentMethod)
        } else {
            interactor?.createExpense(amount: amount, date: date, category: selectedCategory, note: note, paymentMethod: selectedPaymentMethod)
        }
    }
}

extension AddExpensePresenter: AddExpenseInteractorOutputProtocol {
    func didFetchCategories(_ categories: [Category]) {
        self.categories = categories
        view?.configureInitialState(categories: categories)
    }
    
    func didFailToFetchCategories(_ error: Error) {
        view?.showValidationError(error.localizedDescription)
    }
    
    func didCreateExpense(_ expense: Expense) {
        view?.hideSaving()
        delegate?.addExpenseModuleDidCreateExpense(expense)
        router?.dismiss(view: view)
    }
    
    func didFailToCreateExpense(_ error: Error) {
        view?.hideSaving()
        view?.showValidationError(error.localizedDescription)
    }
    
    func didUpdateExpense(_ expense: Expense) {
        view?.hideSaving()
        delegate?.addExpenseModuleDidUpdateExpense(expense)
        router?.dismiss(view: view)
    }
    
    func didFailToUpdateExpense(_ error: Error) {
        view?.hideSaving()
        view?.showValidationError(error.localizedDescription)
    }
}
