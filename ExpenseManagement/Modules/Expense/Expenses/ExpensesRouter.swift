//
//  ExpensesRouter.swift
//  ExpenseManagement
//
//  Created by Afsal Baaqir A on 19/02/26.
//

import UIKit

final class ExpensesRouter: ExpensesRouterProtocol {
    
    weak var viewController: UIViewController?
    
    static func createModule() -> UINavigationController {
        let view = ExpensesViewController()
        let presenter = ExpensesPresenter()
        let interactor = ExpensesInteractor()
        let router = ExpensesRouter()
        
        view.presenter = presenter
        presenter.view = view
        presenter.interactor = interactor
        presenter.router = router
        interactor.presenter = presenter
        router.viewController = view
        
        let navigationController = UINavigationController(rootViewController: view)
        return navigationController
    }
    
    func navigateToAddExpense(from view: ExpensesViewProtocol?, delegate: AddExpenseModuleDelegate) {
        let addExpenseVC = AddExpenseRouter.createModuleForNew(delegate: delegate)
        (view as? UIViewController)?.present(addExpenseVC, animated: true)
    }
    
    func navigateToEditExpense(from view: ExpensesViewProtocol?, expense: Expense, delegate: AddExpenseModuleDelegate) {
        let editExpenseVC = AddExpenseRouter.createModuleForEditing(expense: expense, delegate: delegate)
        (view as? UIViewController)?.present(editExpenseVC, animated: true)
    }
}
