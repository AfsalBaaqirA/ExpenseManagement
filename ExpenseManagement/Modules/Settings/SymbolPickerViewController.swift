//
//  SymbolPickerViewController.swift
//  ExpenseManagement
//
//  Created by Afsal Baaqir A on 21/02/26.
//

import UIKit

final class SymbolPickerViewController: UIViewController {
    var onSymbolPicked: ((String) -> Void)?
    private let allSymbols: [String]
    private var filteredSymbols: [String]
    private var selectedSymbolName: String?
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search SF Symbols"
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        return searchBar
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 12
        layout.minimumInteritemSpacing = 12
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(SymbolCell.self, forCellWithReuseIdentifier: SymbolCell.reuseIdentifier)
        collectionView.backgroundColor = .systemBackground
        return collectionView
    }()
    
    init(selectedSymbolName: String?) {
        self.selectedSymbolName = selectedSymbolName
        self.allSymbols = SFSymbolsDataSource.allSymbols
        self.filteredSymbols = allSymbols
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Choose Icon"
        
        searchBar.delegate = self
        collectionView.delegate = self
        collectionView.dataSource = self
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelTapped))
        
        view.addSubview(searchBar)
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            
            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        if let selected = selectedSymbolName, let index = filteredSymbols.firstIndex(of: selected) {
            let indexPath = IndexPath(item: index, section: 0)
            collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .centeredVertically)
        }
    }
    
    @objc private func cancelTapped() {
        dismiss(animated: true)
    }
}

// MARK: - UICollectionViewDataSource, Delegate, FlowLayout
extension SymbolPickerViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredSymbols.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SymbolCell.reuseIdentifier, for: indexPath) as? SymbolCell else {
            return UICollectionViewCell()
        }
        let symbolName = filteredSymbols[indexPath.item]
        cell.configure(with: symbolName)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let symbolName = filteredSymbols[indexPath.item]
        selectedSymbolName = symbolName
        onSymbolPicked?(symbolName)
        dismiss(animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let minItemWidth: CGFloat = 50
        let layout = collectionViewLayout as? UICollectionViewFlowLayout
        let spacing = layout?.minimumInteritemSpacing ?? 12
        
        let availableWidth = collectionView.bounds.width
        if availableWidth <= 0 { return CGSize(width: minItemWidth, height: minItemWidth) }
        
        var itemsPerRow = floor((availableWidth + spacing) / (minItemWidth + spacing))
        if itemsPerRow < 5 { itemsPerRow = 5 }
        
        let totalSpacing = spacing * (itemsPerRow - 1)
        let itemWidth = floor((availableWidth - totalSpacing) / itemsPerRow)
        return CGSize(width: itemWidth, height: itemWidth)
    }
}

// MARK: - UISearchBarDelegate
extension SymbolPickerViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredSymbols = allSymbols
        } else {
            filteredSymbols = allSymbols.filter { $0.localizedCaseInsensitiveContains(searchText) }
        }
        collectionView.reloadData()
    }
}

// MARK: - SymbolCell
final class SymbolCell: UICollectionViewCell {
    static let reuseIdentifier = "SymbolCell"
    
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFit
        iv.tintColor = .label
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        contentView.layer.cornerRadius = 8
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.systemGray4.cgColor
        contentView.backgroundColor = .secondarySystemBackground
        
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 24),
            imageView.heightAnchor.constraint(equalToConstant: 24)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var isSelected: Bool {
        didSet {
            contentView.layer.borderColor = isSelected ? UIColor.systemBlue.cgColor : UIColor.systemGray4.cgColor
            contentView.backgroundColor = isSelected ? UIColor.systemBlue.withAlphaComponent(0.1) : .secondarySystemBackground
        }
    }
    
    func configure(with symbolName: String) {
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular)
        imageView.image = UIImage(systemName: symbolName, withConfiguration: config)
    }
}
