//
//  ProfilePresenter.swift
//  ExpenseManagement
//
//  Created by Afsal Baaqir A on 21/02/26.
//

import Foundation

final class ProfilePresenter: ProfilePresenterProtocol {
    weak var view: ProfileViewProtocol?
    var interactor: ProfileInteractorInputProtocol?
    var router: ProfileRouterProtocol?
    
    func viewDidLoad() {
        interactor?.fetchCategories()
    }
    
    func didTapAddCategory() {
        router?.presentCategoryEditor(from: view, category: nil)
    }
    
    func didSelectCategory(_ category: Category) {
        router?.presentCategoryEditor(from: view, category: category)
    }
    
    func didCreateOrUpdateCategory(name: String, iconName: String, colorHex: String, existing: Category?) {
        if let existing = existing {
            interactor?.updateCategory(existing, name: name, iconName: iconName, colorHex: colorHex)
        } else {
            interactor?.createCategory(name: name, iconName: iconName, colorHex: colorHex)
        }
    }
}

extension ProfilePresenter: ProfileInteractorOutputProtocol {
    func didFetchCategories(_ categories: [Category]) {
        DispatchQueue.main.async { [weak self] in
            self?.view?.showCategories(categories)
        }
    }
    
    func didFail(with error: Error) {
        DispatchQueue.main.async { [weak self] in
            self?.view?.showError(error.localizedDescription)
        }
    }
}
