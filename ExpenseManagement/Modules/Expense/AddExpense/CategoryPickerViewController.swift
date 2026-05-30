//
//  CategoryPickerViewController.swift
//  ExpenseManagement
//
//  Created by Afsal Baaqir A on 20/02/26.
//

import UIKit

protocol CategoryPickerViewControllerDelegate: AnyObject {
    func categoryPicker(_ picker: CategoryPickerViewController, didSelectCategoryAt index: Int)
}

final class CategoryPickerViewController: UIViewController {
    
    // MARK: - Public API
    var categories: [Category] = []
    var selectedCategory: Category?
    weak var delegate: CategoryPickerViewControllerDelegate?
    
    // MARK: - UI
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Select Category"
        view.backgroundColor = .systemGroupedBackground
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel,
                                                           target: self,
                                                           action: #selector(cancelTapped))
        
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    @objc private func cancelTapped() {
        dismiss(animated: true)
    }
}

extension CategoryPickerViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ?? UITableViewCell(style: .default, reuseIdentifier: "cell")
        let category = categories[indexPath.row]
        cell.textLabel?.text = category.safeName
        if let selected = selectedCategory, selected == category {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let index = indexPath.row
        delegate?.categoryPicker(self, didSelectCategoryAt: index)
    }
}
