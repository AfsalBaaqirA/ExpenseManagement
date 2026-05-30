//
//  CategoryFilterViewController.swift
//  ExpenseManagement
//
//  Created by Afsal Baaqir A on 20/02/26.
//


import UIKit

protocol CategoryFilterViewControllerDelegate: AnyObject {
    func categoryFilterViewControllerDidSelectAll(_ controller: CategoryFilterViewController)
    func categoryFilterViewController(_ controller: CategoryFilterViewController, didSelect category: Category)
}

final class CategoryFilterViewController: UIViewController {
    weak var delegate: CategoryFilterViewControllerDelegate?
    private let categories: [Category]
    
    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .insetGrouped)
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    init(categories: [Category], delegate: CategoryFilterViewControllerDelegate?) {
        self.categories = categories
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .pageSheet
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Filter by Category"
        view.backgroundColor = .systemBackground
        setupTableView()
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        tableView.dataSource = self
        tableView.delegate = self
    }
}

extension CategoryFilterViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int { 2 }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : categories.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 1 ? "Categories" : nil
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        if indexPath.section == 0 {
            cell.textLabel?.text = "All"
            cell.textLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        } else {
            let category = categories[indexPath.row]
            cell.textLabel?.text = category.safeName
        }
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 {
            delegate?.categoryFilterViewControllerDidSelectAll(self)
        } else {
            let category = categories[indexPath.row]
            delegate?.categoryFilterViewController(self, didSelect: category)
        }
        dismiss(animated: true)
    }
}
