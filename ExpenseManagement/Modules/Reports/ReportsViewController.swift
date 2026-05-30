//
//  ReportsViewController.swift
//  ExpenseManagement
//
//  Created by Afsal Baaqir A on 21/02/26.
//

import UIKit

final class ReportsViewController: UIViewController, ReportsViewProtocol {
    
    var presenter: ReportsPresenterProtocol?

    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()

    // Hero card
    private let heroCardView = UIView()
    private let heroMonthLabel = UILabel()
    private let heroTotalTitleLabel = UILabel()
    private let heroTotalValueLabel = UILabel()
    private let heroChangeLabel = UILabel()

    // Month selector
    private let monthLabel = UILabel()
    private let previousButton = UIButton(type: .system)
    private let nextButton = UIButton(type: .system)
    private let monthNavCard = UIView()
    private var currentMonthDate: Date?
    private let monthListFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }()

    // Chart card
    private let chartCardView = UIView()
    private let pieChartView = ArcChartView()
    private let legendStackView = UIStackView()
    
    private let chartStack = UIStackView()
    private let divider = UIView()

    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    private let emptyLabel = UILabel()
    
    private var chartHeightConstraint: NSLayoutConstraint!
    private var chartWidthLandscapeConstraint: NSLayoutConstraint!
    private var chartMinHeightConstraint: NSLayoutConstraint!
    private var chartPortraitWidthConstraint: NSLayoutConstraint!

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupViews()
        presenter?.viewDidLoad()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        updateChartLayout()
    }

    private func setupNavigationBar() {
        title = "Reports"
        navigationController?.navigationBar.prefersLargeTitles = false
    }

    // MARK: - View setup
    private func setupViews() {
        view.backgroundColor = .systemBackground

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceVertical = true
        scrollView.backgroundColor = .clear
        view.addSubview(scrollView)

        contentStack.axis = .vertical
        contentStack.spacing = 20
        contentStack.alignment = .fill
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStack)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 20),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 16),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -16),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -24)
        ])

        setupHeroCard()
        setupMonthNav()
        setupChartCard()

        emptyLabel.font = .systemFont(ofSize: 15)
        emptyLabel.textColor = .secondaryLabel
        emptyLabel.textAlignment = .center
        emptyLabel.numberOfLines = 0
        emptyLabel.isHidden = true

        activityIndicator.hidesWhenStopped = true
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

        contentStack.addArrangedSubview(heroCardView)
        contentStack.addArrangedSubview(monthNavCard)
        contentStack.addArrangedSubview(chartCardView)
        contentStack.addArrangedSubview(emptyLabel)

        pieChartView.translatesAutoresizingMaskIntoConstraints = false
        chartHeightConstraint = pieChartView.heightAnchor.constraint(equalTo: pieChartView.widthAnchor)
        chartHeightConstraint.isActive = true

        pieChartView.widthAnchor.constraint(lessThanOrEqualToConstant: 600).isActive = true
        chartMinHeightConstraint = pieChartView.heightAnchor.constraint(greaterThanOrEqualToConstant: 220)
        chartMinHeightConstraint.isActive = true
        chartPortraitWidthConstraint = pieChartView.widthAnchor.constraint(equalTo: chartStack.widthAnchor)
        chartPortraitWidthConstraint.isActive = true
    }

    private func setupHeroCard() {
        heroCardView.subviews.filter { $0 is UIVisualEffectView }.forEach { $0.removeFromSuperview() }
        heroCardView.layer.borderWidth = 0
        heroCardView.layer.borderColor = nil
        heroCardView.backgroundColor = .clear
        heroCardView.layer.cornerRadius = 24
        
        heroCardView.layer.cornerCurve = .continuous
        heroCardView.clipsToBounds = false

        let glassEffect = UIGlassEffect()
        glassEffect.isInteractive = false
        let glassView = UIVisualEffectView(effect: glassEffect)
        glassView.translatesAutoresizingMaskIntoConstraints = false
        glassView.layer.cornerRadius = 24
        glassView.layer.cornerCurve = .continuous
        glassView.clipsToBounds = false
        heroCardView.addSubview(glassView)
        
        NSLayoutConstraint.activate([
            glassView.topAnchor.constraint(equalTo: heroCardView.topAnchor),
            glassView.leadingAnchor.constraint(equalTo: heroCardView.leadingAnchor),
            glassView.trailingAnchor.constraint(equalTo: heroCardView.trailingAnchor),
            glassView.bottomAnchor.constraint(equalTo: heroCardView.bottomAnchor)
        ])
        
        glassView.layer.borderColor = UIColor.separator.cgColor
        glassView.layer.borderWidth = 0.5
        
        // Content layout
        heroMonthLabel.font = .systemFont(ofSize: 12, weight: .semibold)
        heroMonthLabel.textColor = .secondaryLabel
        heroMonthLabel.adjustsFontForContentSizeCategory = true

        heroTotalTitleLabel.font = .systemFont(ofSize: 11, weight: .regular)
        heroTotalTitleLabel.textColor = .secondaryLabel
        heroTotalTitleLabel.text = "TOTAL SPENT"
        heroTotalTitleLabel.adjustsFontForContentSizeCategory = true

        heroTotalValueLabel.font = .monospacedDigitSystemFont(ofSize: 34, weight: .bold)
        heroTotalValueLabel.textColor = .label
        heroTotalValueLabel.adjustsFontForContentSizeCategory = true

        heroChangeLabel.font = .systemFont(ofSize: 13, weight: .medium)
        heroChangeLabel.adjustsFontForContentSizeCategory = true

        let heroStack = UIStackView(arrangedSubviews: [
            heroMonthLabel,
            heroTotalTitleLabel,
            heroTotalValueLabel,
            heroChangeLabel
        ])
        heroStack.axis = .vertical
        heroStack.spacing = 5
        heroStack.translatesAutoresizingMaskIntoConstraints = false

        glassView.contentView.addSubview(heroStack)
        NSLayoutConstraint.activate([
            heroStack.topAnchor.constraint(equalTo: glassView.contentView.topAnchor, constant: 22),
            heroStack.leadingAnchor.constraint(equalTo: glassView.contentView.leadingAnchor, constant: 22),
            heroStack.trailingAnchor.constraint(equalTo: glassView.contentView.trailingAnchor, constant: -22),
            heroStack.bottomAnchor.constraint(equalTo: glassView.contentView.bottomAnchor, constant: -22)
        ])
    }

    // MARK: - Month Navigation
    private var calendar = Calendar.current

    private var todayMonth: Date {
        calendar.date(from: calendar.dateComponents([.year, .month], from: Date()))!
    }

    private func setupMonthNav() {

        monthNavCard.backgroundColor = .clear
        monthNavCard.layer.cornerRadius = 20
        monthNavCard.layer.cornerCurve = .continuous
        monthNavCard.clipsToBounds = false

        let glassEffect = UIGlassEffect()
        let glassView = UIVisualEffectView(effect: glassEffect)
        glassView.translatesAutoresizingMaskIntoConstraints = false
        glassView.layer.cornerRadius = 20
        glassView.layer.cornerCurve = .continuous
        glassView.clipsToBounds = true

        glassView.isUserInteractionEnabled = false

        monthNavCard.addSubview(glassView)

        NSLayoutConstraint.activate([
            glassView.topAnchor.constraint(equalTo: monthNavCard.topAnchor),
            glassView.leadingAnchor.constraint(equalTo: monthNavCard.leadingAnchor),
            glassView.trailingAnchor.constraint(equalTo: monthNavCard.trailingAnchor),
            glassView.bottomAnchor.constraint(equalTo: monthNavCard.bottomAnchor)
        ])

        glassView.layer.borderColor = UIColor.separator.cgColor
        glassView.layer.borderWidth = 0.5

        configureChevronButton(previousButton, systemName: "chevron.left")
        configureChevronButton(nextButton, systemName: "chevron.right")

        previousButton.addTarget(self, action: #selector(didTapPrevious), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(didTapNext), for: .touchUpInside)

        monthLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        monthLabel.textAlignment = .center
        monthLabel.textColor = .label

        let navStack = UIStackView(arrangedSubviews: [
            previousButton,
            monthLabel,
            nextButton
        ])

        navStack.axis = .horizontal
        navStack.alignment = .center
        navStack.spacing = 12
        navStack.translatesAutoresizingMaskIntoConstraints = false

        monthNavCard.addSubview(navStack)

        NSLayoutConstraint.activate([
            navStack.topAnchor.constraint(equalTo: monthNavCard.topAnchor, constant: 10),
            navStack.leadingAnchor.constraint(equalTo: monthNavCard.leadingAnchor, constant: 14),
            navStack.trailingAnchor.constraint(equalTo: monthNavCard.trailingAnchor, constant: -14),
            navStack.bottomAnchor.constraint(equalTo: monthNavCard.bottomAnchor, constant: -10),

            previousButton.widthAnchor.constraint(equalToConstant: 36),
            previousButton.heightAnchor.constraint(equalToConstant: 36),
            nextButton.widthAnchor.constraint(equalToConstant: 36),
            nextButton.heightAnchor.constraint(equalToConstant: 36)
        ])
    }

    private func configureChevronButton(_ button: UIButton, systemName: String) {

        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear

        let config = UIImage.SymbolConfiguration(pointSize: 13, weight: .semibold)
        button.setImage(UIImage(systemName: systemName, withConfiguration: config), for: .normal)
        button.tintColor = .label
    }

    private func setupChartCard() {
        chartCardView.subviews.filter { $0 is UIVisualEffectView }.forEach { $0.removeFromSuperview() }
        chartCardView.layer.borderWidth = 0
        chartCardView.layer.borderColor = nil
        chartCardView.backgroundColor = .clear
        chartCardView.layer.cornerRadius = 24
        chartCardView.layer.cornerCurve = .continuous
        chartCardView.clipsToBounds = false

        let glassEffect = UIGlassEffect()
        glassEffect.isInteractive = false
        let glassView = UIVisualEffectView(effect: glassEffect)
        glassView.translatesAutoresizingMaskIntoConstraints = false
        glassView.layer.cornerRadius = 24
        glassView.layer.cornerCurve = .continuous
        glassView.clipsToBounds = false
        chartCardView.addSubview(glassView)
        NSLayoutConstraint.activate([
            glassView.topAnchor.constraint(equalTo: chartCardView.topAnchor),
            glassView.leadingAnchor.constraint(equalTo: chartCardView.leadingAnchor),
            glassView.trailingAnchor.constraint(equalTo: chartCardView.trailingAnchor),
            glassView.bottomAnchor.constraint(equalTo: chartCardView.bottomAnchor)
        ])
        
        glassView.layer.borderColor = UIColor.separator.cgColor
        glassView.layer.borderWidth = 0.5

        legendStackView.axis = .vertical
        legendStackView.spacing = 8

        chartStack.axis = .vertical
        chartStack.spacing = 14
        chartStack.alignment = .fill
        chartStack.translatesAutoresizingMaskIntoConstraints = false

        divider.backgroundColor = .separator
        divider.translatesAutoresizingMaskIntoConstraints = false
        divider.heightAnchor.constraint(equalToConstant: 0.5).isActive = true

        chartStack.addArrangedSubview(pieChartView)
        chartStack.addArrangedSubview(divider)
        chartStack.addArrangedSubview(legendStackView)

        glassView.contentView.addSubview(chartStack)

        NSLayoutConstraint.activate([
            chartStack.topAnchor.constraint(equalTo: glassView.contentView.topAnchor, constant: 20),
            chartStack.leadingAnchor.constraint(equalTo: glassView.contentView.leadingAnchor, constant: 20),
            chartStack.trailingAnchor.constraint(equalTo: glassView.contentView.trailingAnchor, constant: -20),
            chartStack.bottomAnchor.constraint(equalTo: glassView.contentView.bottomAnchor, constant: -20)
        ])
    }

    @objc private func didTapPrevious() {
        presenter?.didTapPreviousMonth()
    }

    @objc private func didTapNext() {
        presenter?.didTapNextMonth()
    }

    private func generateMonthOptions(maxYears: Int = 20) -> [Date] {
        let calendar = Calendar.current
        let today = todayMonth
        var months: [Date] = []
        for yearOffset in 0..<maxYears {
            for monthOffset in 0..<12 {
                let offset = -(yearOffset * 12 + monthOffset)
                if let date = calendar.date(byAdding: .month, value: offset, to: today), date <= today {
                    months.append(date)
                }
            }
        }
        let uniqueMonths = Array(Set(months)).sorted(by: { $0 > $1 })
        return uniqueMonths
    }

    func updateMonth(title: String, date: Date, isPreviousEnabled: Bool, isNextEnabled: Bool) {
        currentMonthDate = date
        monthLabel.text = title

        previousButton.isEnabled = true
        nextButton.isEnabled = date < todayMonth

        previousButton.tintColor = previousButton.isEnabled ? .label : .tertiaryLabel
        nextButton.tintColor = nextButton.isEnabled ? .label : .tertiaryLabel
    }


    func updateHeroCard(monthTitle: String, totalText: String, changeText: String?, changeColor: UIColor?) {
        heroMonthLabel.text  = monthTitle.uppercased()
        heroTotalValueLabel.text = totalText
        heroChangeLabel.text = changeText
        heroChangeLabel.textColor = changeColor ?? .secondaryLabel
        heroChangeLabel.isHidden = (changeText == nil)
    }
    
    private func updateChartLayout() {
        let isLandscape = view.bounds.width > view.bounds.height

        if isLandscape {
            chartStack.axis = .horizontal
            chartStack.spacing = 20
            chartStack.alignment = .center
            divider.isHidden = true

            if chartWidthLandscapeConstraint == nil {
                chartWidthLandscapeConstraint = pieChartView.widthAnchor.constraint(
                    equalTo: chartStack.widthAnchor,
                    multiplier: 0.42
                )
            }
            chartPortraitWidthConstraint.isActive = false
            chartWidthLandscapeConstraint.isActive = true
        } else {
            chartStack.axis = .vertical
            chartStack.spacing = 14
            chartStack.alignment = .fill
            divider.isHidden = false

            chartWidthLandscapeConstraint?.isActive = false
            chartPortraitWidthConstraint.isActive = true
        }
    }

    func updateReport(slices: [ReportCategorySliceViewData], totalText: String) {
        emptyLabel.isHidden = true
        chartCardView.isHidden = false
        legendStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        pieChartView.configure(with: slices, totalText: totalText)

        for vm in slices {
            let row = UIStackView()
            row.axis = .horizontal
            row.alignment = .center
            row.spacing = 10
            row.distribution = .fill

            let colorDot = UIView()
            colorDot.backgroundColor = vm.color
            colorDot.layer.cornerRadius = 5
            colorDot.layer.masksToBounds = true
            colorDot.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                colorDot.widthAnchor.constraint(equalToConstant: 10),
                colorDot.heightAnchor.constraint(equalToConstant: 10)
            ])
            let nameLabel = UILabel()
            nameLabel.font = .systemFont(ofSize: 13, weight: .medium)
            nameLabel.textColor = .label
            nameLabel.text = vm.categoryName
            nameLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)

            let amountLabel = UILabel()
            amountLabel.font = .monospacedDigitSystemFont(ofSize: 13, weight: .semibold)
            amountLabel.textColor = .label
            amountLabel.text = vm.amountText
            amountLabel.textAlignment = .right
            amountLabel.setContentHuggingPriority(.required, for: .horizontal)

            let percentageLabel = UILabel()
            percentageLabel.font = .monospacedDigitSystemFont(ofSize: 13, weight: .regular)
            percentageLabel.textColor = .secondaryLabel
            percentageLabel.text = vm.percentageText
            percentageLabel.textAlignment = .right
            percentageLabel.setContentHuggingPriority(.required, for: .horizontal)
            
            let spacer = UIView()
            spacer.setContentHuggingPriority(.defaultHigh, for: .horizontal)

            row.addArrangedSubview(colorDot)
            row.addArrangedSubview(nameLabel)
            row.addArrangedSubview(spacer)
            row.addArrangedSubview(amountLabel)
            row.addArrangedSubview(percentageLabel)
            legendStackView.addArrangedSubview(row)
        }
    }

    func showEmptyState(message: String) {
        emptyLabel.text = message
        emptyLabel.isHidden = false
        chartCardView.isHidden = true
        pieChartView.configure(with: [], totalText: "")
        legendStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
    }
}
