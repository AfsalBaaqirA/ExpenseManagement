//
//  ProfileProtocols.swift
//  ExpenseManagement
//
//  Created by Afsal Baaqir A on 21/02/26.
//

import UIKit
import CoreData

// MARK: - View Protocol
protocol ProfileViewProtocol: AnyObject {
    var presenter: ProfilePresenterProtocol? { get set }
    
    func showCategories(_ categories: [Category])
    func showError(_ message: String)
}

// MARK: - Presenter Protocol
protocol ProfilePresenterProtocol: AnyObject {
    var view: ProfileViewProtocol? { get set }
    var interactor: ProfileInteractorInputProtocol? { get set }
    var router: ProfileRouterProtocol? { get set }
    
    func viewDidLoad()
    func didTapAddCategory()
    func didSelectCategory(_ category: Category)
    func didCreateOrUpdateCategory(name: String, iconName: String, colorHex: String, existing: Category?)
}

// MARK: - Interactor Input Protocol
protocol ProfileInteractorInputProtocol: AnyObject {
    var presenter: ProfileInteractorOutputProtocol? { get set }
    
    func fetchCategories()
    func createCategory(name: String, iconName: String, colorHex: String)
    func updateCategory(_ category: Category, name: String, iconName: String, colorHex: String)
}

// MARK: - Interactor Output Protocol
protocol ProfileInteractorOutputProtocol: AnyObject {
    func didFetchCategories(_ categories: [Category])
    func didFail(with error: Error)
}

// MARK: - Router Protocol
protocol ProfileRouterProtocol: AnyObject {
    static func createModule() -> UIViewController
    func presentCategoryEditor(from view: ProfileViewProtocol?, category: Category?)
}
