//
//  AddExpenseViewController.swift
//  ExpenseManagement
//
//  Created by Afsal Baaqir A on 20/02/26.
//

import CoreData
import UIKit

final class AddExpenseViewController: UIViewController, AddExpenseViewProtocol {
    
    var presenter: AddExpensePresenterProtocol?
    
    private var isEditingMode: Bool = false
    private var selectedCategory: Category?
    private var selectedCategoryIndex: Int?
    
    // MARK: - UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let formStack = UIStackView()
    
    private let amountTextField = UITextField()
    private let categoryTextField = UITextField()
    
    private let datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .inline
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()
    
    private let categoryPicker = UIPickerView()
    private var categories: [Category] = []
    
    private let noteTextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    private let paymentMethodSegmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: [])
        control.translatesAutoresizingMaskIntoConstraints = false
        control.selectedSegmentTintColor = .systemBlue
        return control
    }()
    private var paymentMethods: [PaymentMethod] = []
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupLayout()
        styleUI()
        setupKeyboardDismiss()
        categoryTextField.delegate = self
        presenter?.viewDidLoad()
    }
    
    // MARK: - Setup
    private func setupNavigationBar() {
        title = isEditingMode ? "Edit Expense" : "Add Expense"
        view.backgroundColor = .systemGroupedBackground
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancelTapped)
        )
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: isEditingMode ? "Update" : "Save",
            style: .prominent,
            target: self,
            action: #selector(saveTapped)
        )
    }
    
    private func setupLayout() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        formStack.translatesAutoresizingMaskIntoConstraints = false
        
        formStack.axis = .vertical
        formStack.spacing = 20
        formStack.alignment = .fill
        
        let dateContainer = UIView()
        dateContainer.translatesAutoresizingMaskIntoConstraints = false
        dateContainer.addSubview(datePicker)
        NSLayoutConstraint.activate([
            datePicker.centerXAnchor.constraint(equalTo: dateContainer.centerXAnchor),
            datePicker.topAnchor.constraint(equalTo: dateContainer.topAnchor),
            datePicker.bottomAnchor.constraint(equalTo: dateContainer.bottomAnchor)
        ])

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(formStack)
        
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
            
            formStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            formStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            formStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            formStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24)
        ])
        
        formStack.addArrangedSubview(noteTextView)
        formStack.addArrangedSubview(amountTextField)
        formStack.addArrangedSubview(dateContainer)
        formStack.addArrangedSubview(categoryTextField)
        formStack.addArrangedSubview(paymentMethodSegmentedControl)
        formStack.addArrangedSubview(activityIndicator)
        
        paymentMethodSegmentedControl.heightAnchor.constraint(equalToConstant: 44).isActive = true
        paymentMethodSegmentedControl.centerXAnchor.constraint(equalTo: formStack.centerXAnchor).isActive = true
    }
    
    private func styleUI() {
        styleTextField(amountTextField, placeholder: "Amount")
        styleTextField(categoryTextField, placeholder: "Category")
        amountTextField.keyboardType = .decimalPad
        styleTextView(noteTextView)
        paymentMethodSegmentedControl.selectedSegmentIndex = 0
    }
    
    private func styleTextField(_ textField: UITextField, placeholder: String) {
        textField.placeholder = placeholder
        textField.backgroundColor = .secondarySystemBackground
        textField.layer.cornerRadius = 12
        textField.layer.borderWidth = 1.5
        textField.layer.borderColor = UIColor.systemGray2.cgColor
        textField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        let padding = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 50))
        textField.leftView = padding
        textField.leftViewMode = .always
    }

    private func styleTextView(_ textView: UITextView) {
        textView.backgroundColor = .secondarySystemBackground
        textView.layer.cornerRadius = 12
        textView.layer.borderWidth = 1.5
        textView.layer.borderColor = UIColor.systemGray2.cgColor
        textView.font = .systemFont(ofSize: 16)
        textView.heightAnchor.constraint(equalToConstant: 120).isActive = true
        textView.textContainerInset = UIEdgeInsets(top: 12, left: 8, bottom: 12, right: 8)
    }
    
    private func setupKeyboardDismiss() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - Actions
    @objc private func cancelTapped() {
        presenter?.didTapCancel()
    }
    
    @objc private func saveTapped() {
        view.endEditing(true)
        
        let selectedIndex = selectedCategoryIndex ?? 0
        let selectedPaymentMethodIndex = paymentMethodSegmentedControl.selectedSegmentIndex
        
        presenter?.didTapSave(
            amountText: amountTextField.text,
            date: datePicker.date,
            categoryIndex: selectedIndex,
            note: noteTextView.text,
            paymentMethodIndex: selectedPaymentMethodIndex
        )
    }
    
    func configureInitialState(categories: [Category]) {
        self.categories = categories
        if let first = categories.first, categoryTextField.text?.isEmpty ?? true {
            selectedCategory = first
            selectedCategoryIndex = 0
            categoryTextField.text = first.safeName
        }
    }
    
    func configurePaymentMethods(_ methods: [PaymentMethod]) {
        paymentMethods = methods
        paymentMethodSegmentedControl.removeAllSegments()
        
        for (index, method) in methods.enumerated() {
            paymentMethodSegmentedControl.insertSegment(withTitle: method.displayName, at: index, animated: false)
        }
        
        if !methods.isEmpty {
            paymentMethodSegmentedControl.selectedSegmentIndex = 0
        }
    }
    
    func setSelected(paymentMethod: PaymentMethod) {
        guard let index = paymentMethods.firstIndex(of: paymentMethod) else { return }
        paymentMethodSegmentedControl.selectedSegmentIndex = index
    }
    
    func showValidationError(_ message: String) {
        let alert = UIAlertController(title: "Validation Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    func showSaving() {
        activityIndicator.startAnimating()
        navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    func hideSaving() {
        activityIndicator.stopAnimating()
        navigationItem.rightBarButtonItem?.isEnabled = true
    }
    
    func dismiss() {
        dismiss(animated: true)
    }
    
    func showMode(isEditing: Bool) {
        isEditingMode = isEditing
        title = isEditing ? "Edit Expense" : "Add Expense"
        navigationItem.rightBarButtonItem?.title = isEditing ? "Update" : "Save"
    }
    
    func populateFields(with expense: Expense) {
        amountTextField.text = Decimal(string: String(expense.safeAmount))?.description
        datePicker.date = expense.safeDate
        noteTextView.text = expense.safeNote
        
        if let category = expense.category,
           let index = categories.firstIndex(of: category) {
            selectedCategory = category
            selectedCategoryIndex = index
            categoryTextField.text = category.safeName
        }
        
        setSelected(paymentMethod: expense.paymentMethodEnum)
    }
}

// MARK: - UIPickerViewDelegate & DataSource
extension AddExpenseViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        categories.count
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label: UILabel
        if let reusedLabel = view as? UILabel {
            label = reusedLabel
        } else {
            label = UILabel()
            label.textAlignment = .center
            label.font = .systemFont(ofSize: 17, weight: .regular)
            label.textColor = .label
            label.numberOfLines = 1
        }
        
        if categories.indices.contains(row) {
            label.text = categories[row].safeName
        } else {
            label.text = nil
        }
        
        return label
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 44
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if categories.indices.contains(row) {
            selectedCategoryIndex = row
            selectedCategory = categories[row]
            categoryTextField.text = categories[row].safeName
        }
    }
}

// MARK: - UITextFieldDelegate
extension AddExpenseViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField === categoryTextField {
            presentCategoryPicker()
            return false
        }
        return true
    }
}

// MARK: - Full-screen Category Picker
extension AddExpenseViewController: CategoryPickerViewControllerDelegate {
    private func presentCategoryPicker() {
        let pickerVC = CategoryPickerViewController()
        pickerVC.categories = categories
        pickerVC.selectedCategory = selectedCategory
        pickerVC.delegate = self
        let nav = UINavigationController(rootViewController: pickerVC)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
    }
    
    func categoryPicker(_ picker: CategoryPickerViewController, didSelectCategoryAt index: Int) {
        guard categories.indices.contains(index) else { return }
        selectedCategoryIndex = index
        selectedCategory = categories[index]
        categoryTextField.text = categories[index].safeName
        picker.dismiss(animated: true)
    }
}
