//
//  ExpenseCell.swift
//  ExpenseManagement
//
//  Created by Afsal Baaqir A on 16/02/26.
//


import UIKit

class ExpenseCell: UITableViewCell {
    
    static let identifier = "ExpenseCell"
    
    private let glassView: UIVisualEffectView = {
        let effect = UIGlassEffect()
        effect.isInteractive = true
        
        let view = UIVisualEffectView(effect: effect)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 16
        view.layer.cornerCurve = .continuous
        view.clipsToBounds = true
        view.layer.borderWidth = 0.5
        view.layer.borderColor = UIColor.separator.withAlphaComponent(0.4).cgColor
        return view
    }()
    
    private let iconView = UIView()
    private let iconImageView = UIImageView()
    private let categoryLabel = UILabel()
    private let noteLabel = UILabel()
    private let dateLabel = UILabel()
    private let amountLabel = UILabel()
    
    private(set) var isExpanded: Bool = false
    
    private let paymentMethodLabel = UILabel()
    private let updatedDateLabel = UILabel()
    private var expandedStackBottomConstraint: NSLayoutConstraint?
    private var collapsedBottomConstraint: NSLayoutConstraint?
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupCell() {
        backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(glassView)
        
        NSLayoutConstraint.activate([
            glassView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            glassView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            glassView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            glassView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6)
        ])
        
        setupLayout()
    }
    
    private func setupLayout() {
        let content = glassView.contentView
        
        iconView.layer.cornerRadius = 24
        iconView.translatesAutoresizingMaskIntoConstraints = false
        
        iconImageView.tintColor = .white
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        
        categoryLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        categoryLabel.translatesAutoresizingMaskIntoConstraints = false
        
        noteLabel.font = .systemFont(ofSize: 14)
        noteLabel.textColor = .secondaryLabel
        noteLabel.translatesAutoresizingMaskIntoConstraints = false
        
        dateLabel.font = .systemFont(ofSize: 12)
        dateLabel.textColor = .tertiaryLabel
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        amountLabel.font = .systemFont(ofSize: 18, weight: .bold)
        amountLabel.textAlignment = .right
        amountLabel.translatesAutoresizingMaskIntoConstraints = false
        
        paymentMethodLabel.font = .systemFont(ofSize: 13)
        paymentMethodLabel.textColor = .secondaryLabel
        paymentMethodLabel.translatesAutoresizingMaskIntoConstraints = false
        paymentMethodLabel.numberOfLines = 1
        
        updatedDateLabel.font = .systemFont(ofSize: 13)
        updatedDateLabel.textColor = .tertiaryLabel
        updatedDateLabel.translatesAutoresizingMaskIntoConstraints = false
        updatedDateLabel.numberOfLines = 1
        
        content.addSubview(iconView)
        iconView.addSubview(iconImageView)
        content.addSubview(categoryLabel)
        content.addSubview(noteLabel)
        content.addSubview(dateLabel)
        content.addSubview(amountLabel)
        content.addSubview(paymentMethodLabel)
        content.addSubview(updatedDateLabel)
        
        NSLayoutConstraint.activate([
            iconView.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: 14),
            iconView.topAnchor.constraint(equalTo: content.topAnchor, constant: 14),
            iconView.widthAnchor.constraint(equalToConstant: 48),
            iconView.heightAnchor.constraint(equalToConstant: 48),
            
            iconImageView.centerXAnchor.constraint(equalTo: iconView.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalToConstant: 24),
            
            categoryLabel.topAnchor.constraint(equalTo: content.topAnchor, constant: 14),
            categoryLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 12),
            categoryLabel.trailingAnchor.constraint(equalTo: amountLabel.leadingAnchor, constant: -8),
            
            noteLabel.topAnchor.constraint(equalTo: categoryLabel.bottomAnchor, constant: 2),
            noteLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 12),
            noteLabel.trailingAnchor.constraint(equalTo: amountLabel.leadingAnchor, constant: -8),
            
            dateLabel.topAnchor.constraint(equalTo: noteLabel.bottomAnchor, constant: 2),
            dateLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 12),
            
            amountLabel.centerYAnchor.constraint(equalTo: iconView.centerYAnchor),
            amountLabel.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -14),
            amountLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 80),
            
            paymentMethodLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 8),
            paymentMethodLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 12),
            paymentMethodLabel.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -14),
            
            updatedDateLabel.topAnchor.constraint(equalTo: paymentMethodLabel.bottomAnchor, constant: 4),
            updatedDateLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 12),
            updatedDateLabel.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -14)
        ])
        
        expandedStackBottomConstraint = updatedDateLabel.bottomAnchor.constraint(equalTo: content.bottomAnchor, constant: -10)
        collapsedBottomConstraint = dateLabel.bottomAnchor.constraint(equalTo: content.bottomAnchor, constant: -10)
        collapsedBottomConstraint?.isActive = true
        paymentMethodLabel.alpha = 0
        updatedDateLabel.alpha = 0
    }
    
    // MARK: - Configure
    func configure(with expense: Expense) {
        categoryLabel.text = expense.categoryName
        noteLabel.text = expense.safeNote
        amountLabel.text = "-$\(String(format: "%.2f", expense.safeAmount))"
        amountLabel.textColor = .systemRed

        iconView.backgroundColor = expense.categoryColor
        iconImageView.image = UIImage(systemName: expense.categoryIcon)

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy"
        dateLabel.text = dateFormatter.string(from: expense.safeDate)

        let paymentMethod = expense.safePaymentMethod
        paymentMethodLabel.text = "Payment method: \(paymentMethod)"
        
        let updatedDate = expense.safeUpdatedDate
        let updatedDateFormatter = DateFormatter()
        updatedDateFormatter.dateFormat = "MMM dd, yyyy 'at' HH:mm"
        updatedDateLabel.text = "Updated: \(updatedDateFormatter.string(from: updatedDate))"
    }
    
    // MARK: - Expansion Handling
    func setExpanded(_ expanded: Bool, animated: Bool) {
        isExpanded = expanded

        collapsedBottomConstraint?.isActive = !expanded
        expandedStackBottomConstraint?.isActive = expanded

        let changes = {
            self.paymentMethodLabel.alpha = expanded ? 1.0 : 0.0
            self.updatedDateLabel.alpha = expanded ? 1.0 : 0.0
            self.layoutIfNeeded()
        }

        if animated {
            UIView.animate(withDuration: 0.25, animations: changes)
        } else {
            changes()
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        setExpanded(false, animated: false)
    }
}
