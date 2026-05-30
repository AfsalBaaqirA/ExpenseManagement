//
//  ProfileRouter.swift
//  ExpenseManagement
//
//  Created by Afsal Baaqir A on 21/02/26.
//

import UIKit

final class ProfileRouter: ProfileRouterProtocol {
    static func createModule() -> UIViewController {
        let view = ProfileViewController()
        let presenter = ProfilePresenter()
        let interactor = ProfileInteractor()
        let router = ProfileRouter()
        
        view.presenter = presenter
        presenter.view = view
        presenter.interactor = interactor
        presenter.router = router
        interactor.presenter = presenter
        
        let navController = UINavigationController(rootViewController: view)
        return navController
    }
    
    func presentCategoryEditor(from view: ProfileViewProtocol?, category: Category?) {
        guard let vc = view as? UIViewController else { return }
        let editor = CategoryEditorViewController(category: category, delegate: vc as? CategoryEditorDelegate)
        let nav = UINavigationController(rootViewController: editor)
        vc.present(nav, animated: true)
    }
}
