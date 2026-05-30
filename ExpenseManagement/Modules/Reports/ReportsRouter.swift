//
//  ReportsRouter.swift
//  ExpenseManagement
//
//  Created by Afsal Baaqir A on 21/02/26.
//


import UIKit

final class ReportsRouter: ReportsRouterProtocol {
    static func createModule() -> UIViewController {
        let view = ReportsViewController()
        let presenter = ReportsPresenter()
        let interactor = ReportsInteractor()
        let router = ReportsRouter()
        
        view.presenter = presenter
        presenter.view = view
        presenter.interactor = interactor
        presenter.router = router
        interactor.presenter = presenter
        
        let navigationController = UINavigationController(rootViewController: view)
        return navigationController
    }
}
