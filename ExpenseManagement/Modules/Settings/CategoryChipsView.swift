//
//  CategoryChipsView.swift
//  ExpenseManagement
//
//  Created by Afsal Baaqir A on 22/02/26.
//

import UIKit

final class CategoryChipCell: UICollectionViewCell {
    static let reuseIdentifier = "CategoryChipCell"
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.setContentHuggingPriority(.required, for: .horizontal)
        imageView.setContentCompressionResistancePriority(.required, for: .horizontal)
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return label
    }()
    
    private let contentStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 6
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        contentView.layer.cornerRadius = 16
        contentView.layer.masksToBounds = true
        contentView.backgroundColor = .secondarySystemBackground
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.separator.cgColor
        
        contentView.addSubview(contentStack)
        contentStack.addArrangedSubview(iconImageView)
        contentStack.addArrangedSubview(nameLabel)
        
        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            contentStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            contentStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            contentStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            
            iconImageView.widthAnchor.constraint(equalToConstant: 18),
            iconImageView.heightAnchor.constraint(equalToConstant: 18)
        ])
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        iconImageView.image = nil
        nameLabel.text = nil
        nameLabel.textColor = .label
        iconImageView.tintColor = .label
    }
    
    func configure(with category: Category) {
        nameLabel.text = category.safeName
        let color = UIColor(hex: category.safeColorHex) ?? .systemBlue
        nameLabel.textColor = color
        iconImageView.tintColor = color
        
        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
        let symbolName = category.safeIconName
        let image = UIImage(systemName: symbolName, withConfiguration: config) ?? UIImage(systemName: "circle.fill", withConfiguration: config)
        iconImageView.image = image
        
        isAccessibilityElement = true
        accessibilityLabel = category.safeName
        accessibilityTraits = .button
    }
}

final class CategoryChipsView: UIView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    var onCategoryTapped: ((Category) -> Void)?
    
    private var categories: [Category] = []
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 8
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.backgroundColor = .clear
        collection.showsVerticalScrollIndicator = true
        collection.alwaysBounceVertical = true
        return collection
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        collectionView.register(CategoryChipCell.self, forCellWithReuseIdentifier: CategoryChipCell.reuseIdentifier)
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    func configure(with categories: [Category]) {
        self.categories = categories
        print("CategoryChipsView.configure categories=\(categories.count)")
        collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("CategoryChipsView.numberOfItemsInSection = \(categories.count)")
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryChipCell.reuseIdentifier, for: indexPath) as? CategoryChipCell else {
            return UICollectionViewCell()
        }
        let category = categories[indexPath.item]
        print("Configuring chip for category: \(category.safeName)")
        cell.configure(with: category)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let category = categories[indexPath.item]
        onCategoryTapped?(category)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 4, left: 0, bottom: 4, right: 0)
    }
}
