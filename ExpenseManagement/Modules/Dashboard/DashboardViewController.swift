//
//  DashboardViewController.swift
//  ExpenseManagement
//
//  Created by Afsal Baaqir A on 14/02/26.
//


import UIKit
import CoreData

final class DashboardViewController: UIViewController, DashboardViewProtocol {
    var presenter: DashboardPresenterProtocol?
    
    private var expenses: [Expense] = []
    private var currentIncomeDisplayValue: String = "$0"
    
    // MARK: - UI Components
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let summaryStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let incomeCard = SummaryCardView()
    private let expensesCard = SummaryCardView()
    private let savingsCard = SummaryCardView()
    
    private let recentExpensesHeaderView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let recentExpensesLabel: UILabel = {
        let label = UILabel()
        label.text = "Recent Expenses"
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let seeAllButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("See All", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.register(ExpenseCell.self, forCellReuseIdentifier: "ExpenseCell")
        table.separatorStyle = .none
        table.backgroundColor = .clear
        table.isScrollEnabled = false
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupUI()
        presenter?.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presenter?.refreshData()
    }
    
    private func setupNavigationBar() {
        title = "Dashboard"
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(scrollView)

        scrollView.addSubview(contentView)
        
        contentView.addSubview(summaryStackView)
        summaryStackView.addArrangedSubview(incomeCard)
        summaryStackView.addArrangedSubview(expensesCard)
        summaryStackView.addArrangedSubview(savingsCard)
        
        contentView.addSubview(recentExpensesHeaderView)
        recentExpensesHeaderView.addSubview(recentExpensesLabel)
        recentExpensesHeaderView.addSubview(seeAllButton)
        contentView.addSubview(tableView)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        
        seeAllButton.addTarget(self, action: #selector(seeAllButtonTapped), for: .touchUpInside)
        
        incomeCard.onTap = { [weak self] in
            self?.presentIncomeEditAlert()
        }
        
        setupConstraints()    }
    
    @objc private func seeAllButtonTapped() {
        presenter?.didSelectSeeAll()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            summaryStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            summaryStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            summaryStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            summaryStackView.heightAnchor.constraint(equalToConstant: 100),
            
            recentExpensesHeaderView.topAnchor.constraint(equalTo: summaryStackView.bottomAnchor, constant: 24),
            recentExpensesHeaderView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            recentExpensesHeaderView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            recentExpensesLabel.topAnchor.constraint(equalTo: recentExpensesHeaderView.topAnchor),
            recentExpensesLabel.leadingAnchor.constraint(equalTo: recentExpensesHeaderView.leadingAnchor),
            recentExpensesLabel.bottomAnchor.constraint(equalTo: recentExpensesHeaderView.bottomAnchor),
            
            seeAllButton.centerYAnchor.constraint(equalTo: recentExpensesLabel.centerYAnchor),
            seeAllButton.trailingAnchor.constraint(equalTo: recentExpensesHeaderView.trailingAnchor),
            
            tableView.topAnchor.constraint(equalTo: recentExpensesHeaderView.bottomAnchor, constant: 12),
            tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            tableView.heightAnchor.constraint(equalToConstant: CGFloat(min(expenses.count, 4) * 100 + 20))
        ])
    }
    
    // MARK: - DashboardViewProtocol
    func showExpenses(_ expenses: [Expense]) {
        self.expenses = expenses
        tableView.reloadData()
        updateTableHeight()
    }
    
    func updateSummary(income: String, expenses: String, savings: String) {
        currentIncomeDisplayValue = income
        incomeCard.configure(title: "Income", value: income, color: .systemBlue)
        expensesCard.configure(title: "Expenses", value: expenses, color: .systemRed)
        savingsCard.configure(title: "Savings", value: savings, color: .systemGreen)
    }
    
    func showError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    func askToPopulateSampleData() {
        let alert = UIAlertController(
            title: "Populate Sample Data?",
            message: "Your app doesn't have any expenses yet. Do you want to populate it with sample data to explore the features?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Not Now", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Populate", style: .default, handler: { [weak self] _ in
            self?.presenter?.didConfirmPopulateSampleData()
        }))
        present(alert, animated: true)
    }
    
    // MARK: - Helper Methods
    private func updateTableHeight() {
        for constraint in tableView.constraints {
            if constraint.firstAttribute == .height {
                constraint.isActive = false
            }
        }
        let rowCount = min(expenses.count, 4)
        tableView.heightAnchor.constraint(equalToConstant: CGFloat(rowCount * 100 + 20)).isActive = true
    }
    
    private func presentIncomeEditAlert() {
            let alert = UIAlertController(title: "Enter Income", message: "Please enter your current income", preferredStyle: .alert)
            alert.addTextField { [weak self] textField in
                textField.keyboardType = .decimalPad
                textField.placeholder = "e.g. 5000"
                textField.text = self?.numericString(from: self?.currentIncomeDisplayValue ?? "")
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self, weak alert] _ in
                guard let self = self,
                      let text = alert?.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines),
                      !text.isEmpty else { return }
                
                let sanitized = text.replacingOccurrences(of: ",", with: "")
                if let value = Double(sanitized), value >= 0 {
                    self.presenter?.didUpdateIncome(value)
                    self.presenter?.refreshData()
                } else {
                    self.showError("Please enter a valid non-negative number for income.")
                }
            }
            
            alert.addAction(cancelAction)
            alert.addAction(saveAction)
            present(alert, animated: true, completion: nil)
        }

        private func numericString(from displayValue: String) -> String {
            let allowed = Set("0123456789.")
            let filtered = displayValue.filter { allowed.contains($0) }
            return filtered
        }
}

// MARK: - TableView Delegate & DataSource
extension DashboardViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return min(expenses.count, 4)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ExpenseCell", for: indexPath) as! ExpenseCell
        let expense = expenses[indexPath.row]
        cell.configure(with: expense)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}

// MARK: - Summary Card View
class SummaryCardView: UIView {
    var onTap: (() -> Void)?
    
    private var glassEffectView: UIVisualEffectView?
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let valueLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        backgroundColor = .clear
        layer.cornerRadius = 16
        layer.cornerCurve = .continuous
        clipsToBounds = false
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tapGesture)
        
        // Glass Effect
        let glassEffect = UIGlassEffect()
        glassEffect.isInteractive = false
        let glassView = UIVisualEffectView(effect: glassEffect)
        glassView.translatesAutoresizingMaskIntoConstraints = false
        glassView.layer.cornerRadius = 16
        glassView.layer.cornerCurve = .continuous
        glassView.clipsToBounds = false
        
        addSubview(glassView)
        
        NSLayoutConstraint.activate([
            glassView.topAnchor.constraint(equalTo: topAnchor),
            glassView.leadingAnchor.constraint(equalTo: leadingAnchor),
            glassView.trailingAnchor.constraint(equalTo: trailingAnchor),
            glassView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        glassView.layer.borderWidth = 0.5
        glassView.layer.borderColor = UIColor.separator.withAlphaComponent(0.4).cgColor
        
        glassEffectView = glassView
        
        glassView.contentView.addSubview(titleLabel)
        glassView.contentView.addSubview(valueLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: glassView.contentView.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: glassView.contentView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: glassView.contentView.trailingAnchor, constant: -12),
            
            valueLabel.bottomAnchor.constraint(equalTo: glassView.contentView.bottomAnchor, constant: -12),
            valueLabel.leadingAnchor.constraint(equalTo: glassView.contentView.leadingAnchor, constant: 12),
            valueLabel.trailingAnchor.constraint(equalTo: glassView.contentView.trailingAnchor, constant: -12)
        ])
    }
    
    @objc private func handleTap() {
        onTap?()
    }

    func configure(title: String, value: String, color: UIColor) {
        titleLabel.text = title
        valueLabel.text = value
        valueLabel.textColor = color
    }
}
