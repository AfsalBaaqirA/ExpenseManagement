//
//  DashboardRouter.swift
//  ExpenseManagement
//
//  Created by Afsal Baaqir A on 14/02/26.
//


import UIKit

final class DashboardRouter: DashboardRouterProtocol {
    weak var viewController: UIViewController?
    
    static func createModule() -> UIViewController {
        let view = DashboardViewController()
        let presenter = DashboardPresenter()
        let interactor = DashboardInteractor()
        let router = DashboardRouter()
        
        view.presenter = presenter
        presenter.view = view
        presenter.interactor = interactor
        presenter.router = router
        interactor.presenter = presenter
        router.viewController = view
        
        let navigationController = UINavigationController(rootViewController: view)
        return navigationController
    }
    
    func navigateToAllExpenses() {
        guard
            let viewController = viewController,
            let tabBarController = viewController.tabBarController
        else { return }
        
        tabBarController.selectedIndex = 1
    }
}
