//
//  CategoryEditorViewController.swift
//  ExpenseManagement
//
//  Created by Afsal Baaqir A on 21/02/26.
//

import UIKit

final class CategoryEditorViewController: UIViewController {
    weak var delegate: CategoryEditorDelegate?
    private var existingCategory: Category?
    private var selectedColor: UIColor = .systemBlue
    
    private let iconPreviewImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .label
        imageView.widthAnchor.constraint(equalToConstant: 24).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 24).isActive = true
        return imageView
    }()
    
    private lazy var nameTextField = makeStyledTextField(placeholder: "Category Name")
    private lazy var iconTextField = makeStyledTextField(placeholder: "Select Symbol")
    private lazy var colorTextField = makeStyledTextField(placeholder: "Select Color")
    
    private let colorPreviewView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        view.widthAnchor.constraint(equalToConstant: 20).isActive = true
        view.heightAnchor.constraint(equalToConstant: 20).isActive = true
        view.layer.borderWidth = 0.5
        view.layer.borderColor = UIColor.separator.cgColor
        return view
    }()
    
    init(category: Category?, delegate: CategoryEditorDelegate?) {
        self.existingCategory = category
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = existingCategory == nil ? "Add Category" : "Edit Category"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveTapped))
        
        nameTextField.delegate = self
        
        iconTextField.delegate = self
        iconTextField.rightView = makeRightContainer(for: iconPreviewImageView)
        iconTextField.rightViewMode = .always
        
        colorTextField.delegate = self
        colorTextField.rightView = makeRightContainer(for: colorPreviewView)
        colorTextField.rightViewMode = .always
        colorPreviewView.backgroundColor = selectedColor
        
        setupLayout()
        populateIfNeeded()
    }
    
    private func setupLayout() {
        let stack = UIStackView(arrangedSubviews: [nameTextField, iconTextField, colorTextField])
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            stack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])
    }
    
    private func populateIfNeeded() {
        if let category = existingCategory {
            nameTextField.text = category.safeName
            iconTextField.text = category.safeIconName
            colorTextField.text = category.safeColorHex
            selectedColor = UIColor(hex: category.safeColorHex) ?? .systemBlue
            updateIconPreview(with: category.safeIconName)
        } else {
            let defaultSymbol = SFSymbolsDataSource.defaultSymbolName
            iconTextField.text = defaultSymbol
            selectedColor = UIColor(hex: "#007AFF") ?? .systemBlue
            colorTextField.text = "#007AFF"
            updateIconPreview(with: defaultSymbol)
        }
    }
    private func makeStyledTextField(placeholder: String) -> UITextField {
        let textField = UITextField()
        textField.placeholder = placeholder
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        textField.font = .systemFont(ofSize: 16, weight: .medium)
        textField.textColor = .label
        
        textField.backgroundColor = UIColor.secondarySystemBackground
        textField.layer.cornerRadius = 12
        textField.layer.masksToBounds = true
        
        textField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        textField.setLeftPadding(16)
        
        return textField
    }
    
    private func makeRightContainer(for view: UIView) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            view.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            view.centerXAnchor.constraint(equalTo: container.centerXAnchor)
        ])
        
        container.widthAnchor.constraint(equalToConstant: 44).isActive = true
        container.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        return container
    }
    
    private func updateIconPreview(with symbolName: String) {
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular)
        iconPreviewImageView.image = UIImage(systemName: symbolName, withConfiguration: config)
        iconPreviewImageView.tintColor = selectedColor
    }
    
    @objc private func cancelTapped() {
        dismiss(animated: true)
    }
    
    @objc private func saveTapped() {
        guard let name = nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !name.isEmpty,
              let icon = iconTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !icon.isEmpty,
              let color = colorTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !color.isEmpty else {
            let alert = UIAlertController(title: "Missing Fields", message: "Please fill in all fields.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        delegate?.categoryEditorDidFinish(name: name, iconName: icon, colorHex: color, existing: existingCategory)
        dismiss(animated: true)
    }
}

extension CategoryEditorViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField === iconTextField {
            let picker = SymbolPickerViewController(selectedSymbolName: iconTextField.text)
            picker.onSymbolPicked = { [weak self] symbolName in
                guard let self = self else { return }
                self.iconTextField.text = symbolName
                self.updateIconPreview(with: symbolName)
            }
            let nav = UINavigationController(rootViewController: picker)
            nav.modalPresentationStyle = .pageSheet
            present(nav, animated: true)
            return false
        } else if textField === colorTextField {
            presentColorPicker()
            return false
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == nameTextField {
            textField.resignFirstResponder()
            iconTextField.becomeFirstResponder()
            return false
        }
        return true
    }
    
    private func presentColorPicker() {
        let picker = UIColorPickerViewController()
        picker.selectedColor = selectedColor
        picker.supportsAlpha = false
        picker.delegate = self
        
        if let sheet = picker.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
        }
        
        present(picker, animated: true)
    }
}

extension CategoryEditorViewController: UIColorPickerViewControllerDelegate {
    
    func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
        selectedColor = viewController.selectedColor
        
        let hex = selectedColor.toHex()
        colorTextField.text = hex
        colorPreviewView.backgroundColor = selectedColor
        
        if let symbol = iconTextField.text {
            updateIconPreview(with: symbol)
        }
    }
}
