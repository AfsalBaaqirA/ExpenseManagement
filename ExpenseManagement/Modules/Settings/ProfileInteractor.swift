//
//  ProfileInteractor.swift
//  ExpenseManagement
//
//  Created by Afsal Baaqir A on 21/02/26.
//

import Foundation
import CoreData

final class ProfileInteractor: ProfileInteractorInputProtocol {
    weak var presenter: ProfileInteractorOutputProtocol?
    
    private let context = CoreDataStack.shared.context
    
    func fetchCategories() {
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        do {
            let categories = try context.fetch(request)
            presenter?.didFetchCategories(categories)
        } catch {
            presenter?.didFail(with: error)
        }
    }
    
    func createCategory(name: String, iconName: String, colorHex: String) {
        let category = Category(context: context)
        category.name = name
        category.iconName = iconName
        category.colorHex = colorHex
        
        saveContext()
        fetchCategories()
    }
    
    func updateCategory(_ category: Category, name: String, iconName: String, colorHex: String) {
        category.name = name
        category.iconName = iconName
        category.colorHex = colorHex
        
        saveContext()
        fetchCategories()
    }
    
    private func saveContext() {
        do {
            try context.save()
        } catch {
            presenter?.didFail(with: error)
        }
    }
}
