//
//  ExpensesPresenter.swift
//  ExpenseManagement
//
//  Created by Afsal Baaqir A on 19/02/26.
//


import Foundation
import UIKit
import CoreData

final class ExpensesPresenter: ExpensesPresenterProtocol {
    
    weak var view: ExpensesViewProtocol?
    var interactor: ExpensesInteractorInputProtocol?
    var router: ExpensesRouterProtocol?
    
    private var expenses: [Expense] = []
    private var allExpenses: [Expense] = []
    private var currentFilterCategory: Category?
    
    func viewDidLoad() {
        view?.showLoading()
        interactor?.fetchAllExpenses()
    }
    
    func refreshData() {
        interactor?.fetchAllExpenses()
    }
    
    func didSelectAddExpense() {
        router?.navigateToAddExpense(from: view, delegate: self)
    }
    
    func didSelectEditExpense(_ expense: Expense) {
        router?.navigateToEditExpense(from: view, expense: expense, delegate: self)
    }
    
    func didRequestDeleteExpense(_ expense: Expense) {
        interactor?.deleteExpense(expense)
    }
    
    // MARK: - Filter
    func didTapFilterButton(from viewController: UIViewController, anchor: UIBarButtonItem?) {
        let categories = fetchAllCategories()
        let filterVC = CategoryFilterViewController(categories: categories, delegate: self)
        let nav = UINavigationController(rootViewController: filterVC)
        nav.modalPresentationStyle = .pageSheet
        
        if let sheet = nav.sheetPresentationController {
            sheet.detents = [ .large()]
            sheet.selectedDetentIdentifier = .medium
            sheet.prefersGrabberVisible = true
        }
        
        viewController.present(nav, animated: true)
    }
    
    func fetchAllCategories() -> [Category] {
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        do {
            let categories = try CoreDataStack.shared.context.fetch(request)
            return categories
        } catch {
            print("Failed to fetch categories: \(error)")
            return []
        }
    }
    
    private func applyCurrentFilter() {
        if let category = currentFilterCategory {
            expenses = allExpenses.filter { $0.category == category }
            let color = UIColor(hex: category.safeColorHex)
            view?.updateFilterState(categoryName: category.safeName, categoryColor: color)
        } else {
            expenses = allExpenses
            view?.updateFilterState(categoryName: nil, categoryColor: nil)
        }
        view?.showExpenses(expenses)
    }
}

extension ExpensesPresenter: CategoryFilterViewControllerDelegate {
    func categoryFilterViewControllerDidSelectAll(_ controller: CategoryFilterViewController) {
        currentFilterCategory = nil
        applyCurrentFilter()
    }
    
    func categoryFilterViewController(_ controller: CategoryFilterViewController, didSelect category: Category) {
        currentFilterCategory = category
        applyCurrentFilter()
    }
}

// MARK: - ExpensesInteractorOutputProtocol
extension ExpensesPresenter: ExpensesInteractorOutputProtocol {
    
    func didFetchExpenses(_ expenses: [Expense]) {
        view?.hideLoading()
        self.allExpenses = expenses
        applyCurrentFilter()
    }
    
    func didFailToFetchExpenses(with error: Error) {
        view?.hideLoading()
        view?.showError(error.localizedDescription)
    }
    
    func didDeleteExpense(_ expense: Expense) {
        if let index = expenses.firstIndex(of: expense) {
            expenses.remove(at: index)
        }
        if let allIndex = allExpenses.firstIndex(of: expense) {
            allExpenses.remove(at: allIndex)
        }
        view?.didDeleteExpense(expense)
    }
    
    func didFailToDeleteExpense(_ error: Error) {
        view?.showError(error.localizedDescription)
    }
}

// MARK: - AddExpenseModuleDelegate
extension ExpensesPresenter: AddExpenseModuleDelegate {
    func addExpenseModuleDidUpdateExpense(_ expense: Expense) {
        interactor?.fetchAllExpenses()
    }
    
    func addExpenseModuleDidCreateExpense(_ expense: Expense) {
        interactor?.fetchAllExpenses()
    }
}
