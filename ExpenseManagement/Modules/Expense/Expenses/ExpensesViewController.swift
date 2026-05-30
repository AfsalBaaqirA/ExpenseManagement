//
//  ExpensesViewController.swift
//  ExpenseManagement
//
//  Created by Afsal Baaqir A on 19/02/26.
//

import UIKit

final class ExpensesViewController: UIViewController {
    
    var presenter: ExpensesPresenterProtocol?
    
    private var filterButtonItem: UIBarButtonItem?
    private let filterIconName = "line.3.horizontal.decrease.circle"
    private let activeFilterIconName = "line.3.horizontal.decrease.circle.fill"
    
    // MARK: - UI Components
    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .plain)
        table.delegate = self
        table.dataSource = self
        table.register(ExpenseCell.self, forCellReuseIdentifier: ExpenseCell.identifier)
        table.separatorStyle = .none
        table.backgroundColor = .clear
        table.translatesAutoresizingMaskIntoConstraints = false
        table.rowHeight = UITableView.automaticDimension
        table.estimatedRowHeight = 80
        return table
    }()
    
    private lazy var refreshControl: UIRefreshControl = {
        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        return refresh
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    private lazy var emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "No expenses yet"
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Data
    private var expenses: [Expense] = []
    
    private var expandedExpense: Expense?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupUI()
        setupConstraints()
        presenter?.viewDidLoad()
    }
    
    // MARK: - Setup
    private func setupNavigationBar() {
        title = "Expenses"
        navigationController?.navigationBar.prefersLargeTitles = false
        
        let addButton = UIBarButtonItem(
            image: UIImage(systemName: "plus"),
            style: .plain,
            target: self,
            action: #selector(addExpenseTapped)
        )
        
        let filterButton = UIBarButtonItem(
            image: UIImage(systemName: filterIconName),
            style: .plain,
            target: self,
            action: #selector(filterButtonTapped)
        )
        self.filterButtonItem = filterButton
        
        let spacer = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        spacer.width = 16
        
        navigationItem.rightBarButtonItems = [addButton, spacer, filterButton]
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        view.addSubview(activityIndicator)
        view.addSubview(emptyStateLabel)
        tableView.backgroundColor = .clear
        tableView.refreshControl = refreshControl
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    // MARK: - Actions
    @objc private func refreshData() {
        presenter?.refreshData()
    }
    
    @objc private func addExpenseTapped() {
        presenter?.didSelectAddExpense()
    }
    
    @objc private func filterButtonTapped() {
        presenter?.didTapFilterButton(from: self, anchor: filterButtonItem)
    }
}

// MARK: - ExpensesViewProtocol
extension ExpensesViewController: ExpensesViewProtocol {
    
    func showExpenses(_ expenses: [Expense]) {
        self.expenses = expenses
        emptyStateLabel.isHidden = !expenses.isEmpty
        tableView.isHidden = expenses.isEmpty
        tableView.reloadData()
        refreshControl.endRefreshing()
    }
    
    func showError(_ message: String) {
        refreshControl.endRefreshing()
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    func showLoading() {
        activityIndicator.startAnimating()
    }
    
    func hideLoading() {
        activityIndicator.stopAnimating()
    }
    
    func didDeleteExpense(_ expense: Expense) {
        
        if expandedExpense == expense {
            expandedExpense = nil
        }

        
        if let index = expenses.firstIndex(of: expense) {
            expenses.remove(at: index)
            let indexPath = IndexPath(row: index, section: 0)
            tableView.deleteRows(at: [indexPath], with: .left)
            
            emptyStateLabel.isHidden = !expenses.isEmpty
            tableView.isHidden = expenses.isEmpty
        }
    }
    
    func updateFilterState(categoryName: String?, categoryColor: UIColor?) {
        if let name = categoryName {
            navigationItem.title = "Expenses - \(name)"
            if let filterButtonItem = filterButtonItem {
                filterButtonItem.image = UIImage(systemName: activeFilterIconName)
                filterButtonItem.tintColor = categoryColor ?? view.tintColor
            }
        } else {
            navigationItem.title = "Expenses"
            if let filterButtonItem = filterButtonItem {
                filterButtonItem.image = UIImage(systemName: filterIconName)
                filterButtonItem.tintColor = nil
            }
        }
    }
}

// MARK: - UITableViewDataSource
extension ExpensesViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return expenses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ExpenseCell.identifier, for: indexPath) as? ExpenseCell else {
            return UITableViewCell()
        }
        let expense = expenses[indexPath.row]
        cell.configure(with: expense)
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension ExpensesViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let expense = expenses[indexPath.row]

        tableView.beginUpdates()

        if expandedExpense == expense {
            expandedExpense = nil
        } else {
            expandedExpense = expense
        }

        tableView.visibleCells.forEach { cell in
            guard let expenseCell = cell as? ExpenseCell,
                  let cellIndexPath = tableView.indexPath(for: expenseCell) else { return }

            let cellExpense = expenses[cellIndexPath.row]
            expenseCell.setExpanded(cellExpense == expandedExpense, animated: true)
        }

        tableView.endUpdates()
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        
        let expense = expenses[indexPath.row]

        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ in
            guard let self = self else { return nil }

            let edit = UIAction( title: "Edit", image: UIImage(systemName: "pencil")) { _ in
                self.presenter?.didSelectEditExpense(expense)
            }

            let delete = UIAction(title: "Delete", image: UIImage(systemName: "trash"), attributes: .destructive) { _ in
                self.presenter?.didRequestDeleteExpense(expense)
            }
            
            let editMenu = UIMenu(title: "", options: .displayInline, preferredElementSize: .automatic, children: [edit])
            let deleteMenu = UIMenu(title: "", options: .displayInline, preferredElementSize: .automatic, children: [delete])

            return UIMenu(title: "", children: [editMenu, deleteMenu])
        }
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        return nil
    }
}
