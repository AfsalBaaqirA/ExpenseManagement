//
//  ProfileViewController.swift
//  ExpenseManagement
//
//  Created by Afsal Baaqir A on 21/02/26.
//

import UIKit

protocol CategoryEditorDelegate: AnyObject {
    func categoryEditorDidFinish(name: String, iconName: String, colorHex: String, existing: Category?)
}

final class ProfileViewController: UIViewController, ProfileViewProtocol {
    var presenter: ProfilePresenterProtocol?
    
    private var categories: [Category] = []
    
    private let categoriesHeaderView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let categoriesTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Categories"
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var addCategoryButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold)
        let image = UIImage(systemName: "plus.circle.fill", withConfiguration: config)
        button.setImage(image, for: .normal)
        button.tintColor = .systemGray
        button.addTarget(self, action: #selector(addCategoryTapped), for: .touchUpInside)
        return button
    }()
    
    private let chipsContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let chipsView: CategoryChipsView = {
        let view = CategoryChipsView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var deleteAllDataButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Delete All Data", for: .normal)
        button.setTitleColor(.systemRed, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        button.addTarget(self, action: #selector(deleteAllDataTapped), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Settings"
        view.backgroundColor = .systemBackground
        print("SettingsViewController.viewDidLoad")
        view.addSubview(categoriesHeaderView)
        categoriesHeaderView.addSubview(categoriesTitleLabel)
        categoriesHeaderView.addSubview(addCategoryButton)
        view.addSubview(chipsContainerView)
        chipsContainerView.addSubview(chipsView)
        view.addSubview(deleteAllDataButton)
        
        chipsView.onCategoryTapped = { [weak self] category in
            self?.presenter?.didSelectCategory(category)
        }
        
        setupConstraints()
        
        presenter?.viewDidLoad()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            categoriesHeaderView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            categoriesHeaderView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            categoriesHeaderView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            
            categoriesTitleLabel.topAnchor.constraint(equalTo: categoriesHeaderView.topAnchor),
            categoriesTitleLabel.leadingAnchor.constraint(equalTo: categoriesHeaderView.leadingAnchor),
            categoriesTitleLabel.bottomAnchor.constraint(equalTo: categoriesHeaderView.bottomAnchor),
            
            addCategoryButton.centerYAnchor.constraint(equalTo: categoriesTitleLabel.centerYAnchor),
            addCategoryButton.leadingAnchor.constraint(greaterThanOrEqualTo: categoriesTitleLabel.trailingAnchor, constant: 8),
            addCategoryButton.trailingAnchor.constraint(equalTo: categoriesHeaderView.trailingAnchor),

            chipsContainerView.topAnchor.constraint(equalTo: categoriesHeaderView.bottomAnchor, constant: 12),
            chipsContainerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 12),
            chipsContainerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -12),

            chipsContainerView.heightAnchor.constraint(greaterThanOrEqualToConstant: 60),

            chipsView.topAnchor.constraint(equalTo: chipsContainerView.topAnchor),
            chipsView.leadingAnchor.constraint(equalTo: chipsContainerView.leadingAnchor),
            chipsView.trailingAnchor.constraint(equalTo: chipsContainerView.trailingAnchor),
            chipsView.bottomAnchor.constraint(equalTo: chipsContainerView.bottomAnchor),

            deleteAllDataButton.topAnchor.constraint(equalTo: chipsContainerView.bottomAnchor, constant: 16),
            deleteAllDataButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            deleteAllDataButton.heightAnchor.constraint(equalToConstant: 20),
            deleteAllDataButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    @objc private func addCategoryTapped() {
        presenter?.didTapAddCategory()
    }
    
    // MARK: - SettingsViewProtocol
    func showCategories(_ categories: [Category]) {
        print("SettingsViewController.showCategories count=\(categories.count)")
        self.categories = categories
        chipsView.configure(with: categories)
    }
    
    func showError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension ProfileViewController: CategoryEditorDelegate {
    func categoryEditorDidFinish(name: String, iconName: String, colorHex: String, existing: Category?) {
        presenter?.didCreateOrUpdateCategory(name: name, iconName: iconName, colorHex: colorHex, existing: existing)
    }
}

extension ProfileViewController {
    @objc private func deleteAllDataTapped() {
        let alert = UIAlertController(title: "Delete All Data",
                                      message: "This will erase all users, expenses, categories, and budgets. This action cannot be undone.",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
            Util.deleteAllData()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                exit(0)
            }
        }))
        present(alert, animated: true)
    }
}
