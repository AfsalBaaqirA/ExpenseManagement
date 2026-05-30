//
//  AddExpenseRouter.swift
//  ExpenseManagement
//
//  Created by Afsal Baaqir A on 20/02/26.
//

import UIKit

final class AddExpenseRouter: AddExpenseRouterProtocol {
    
    weak var viewController: UIViewController?
    
    static func createModule(delegate: AddExpenseModuleDelegate?) -> UIViewController {
        return createModuleForNew(delegate: delegate)
    }
    
    static func createModuleForNew(delegate: AddExpenseModuleDelegate?) -> UIViewController {
        let view = AddExpenseViewController()
        let presenter = AddExpensePresenter()
        let interactor = AddExpenseInteractor()
        let router = AddExpenseRouter()
        
        view.presenter = presenter
        presenter.view = view
        presenter.interactor = interactor
        presenter.router = router
        presenter.delegate = delegate
        interactor.presenter = presenter
        router.viewController = view
        
        presenter.configureForNewExpense()
        
        let navigationController = UINavigationController(rootViewController: view)
        return navigationController
    }
    
    static func createModuleForEditing(expense: Expense, delegate: AddExpenseModuleDelegate?) -> UIViewController {
        let view = AddExpenseViewController()
        let presenter = AddExpensePresenter()
        let interactor = AddExpenseInteractor()
        let router = AddExpenseRouter()
        
        view.presenter = presenter
        presenter.view = view
        presenter.interactor = interactor
        presenter.router = router
        presenter.delegate = delegate
        interactor.presenter = presenter
        router.viewController = view

        presenter.configureForEditing(expense: expense)
        
        let navigationController = UINavigationController(rootViewController: view)
        return navigationController
    }
    
    func dismiss(view: AddExpenseViewProtocol?) {
        (view as? UIViewController)?.dismiss(animated: true)
    }
}
