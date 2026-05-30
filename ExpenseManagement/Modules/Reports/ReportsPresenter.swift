//
//  ReportsPresenter.swift
//  ExpenseManagement
//
//  Created by Afsal Baaqir A on 21/02/26.
//


import Foundation
import UIKit

final class ReportsPresenter: ReportsPresenterProtocol {

    weak var view: ReportsViewProtocol?
    var interactor: ReportsInteractorInputProtocol?
    var router: ReportsRouterProtocol?

    // MARK: - State

    private let calendar = Calendar.current

    private var selectedMonth: Date = Date()

    private var categoryReports: [CategoryReportData] = []
    private var total: Double = 0
    private var previousMonthTotal: Double?

    private lazy var currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        return formatter
    }()
}

// MARK: - Lifecycle

extension ReportsPresenter {

    func viewDidLoad() {
        selectedMonth = normalizedMonth(from: Date())
        updateMonthUI()
        interactor?.fetchReport(for: selectedMonth)
    }
}

// MARK: - Month Navigation

extension ReportsPresenter {

    func didTapPreviousMonth() {
        guard let previous = calendar.date(byAdding: .month, value: -1, to: selectedMonth) else { return }
        selectedMonth = normalizedMonth(from: previous)
        updateMonthUI()
        interactor?.fetchReport(for: selectedMonth)
    }

    func didTapNextMonth() {
        guard let next = calendar.date(byAdding: .month, value: 1, to: selectedMonth) else { return }

        let normalizedNext = normalizedMonth(from: next)
        let currentMonth = normalizedMonth(from: Date())

        guard normalizedNext <= currentMonth else { return }

        selectedMonth = normalizedNext
        updateMonthUI()
        interactor?.fetchReport(for: selectedMonth)
    }
}

// MARK: - Interactor Output
extension ReportsPresenter: ReportsInteractorOutputProtocol {

    func didFetchReport(_ report: MonthlyReportData) {
        // Normalize and store state
        self.selectedMonth = report.monthStart
        self.categoryReports = report.categories.sorted { $0.totalAmount > $1.totalAmount }
        self.total = report.totalAmount
        self.previousMonthTotal = report.previousMonthTotalAmount

        updateView()
    }

    func didFailToFetchReport(error: Error) {
        view?.showEmptyState(message: "Failed to load report.")
    }
}

// MARK: - View Update
private extension ReportsPresenter {

    func updateView() {

        guard !categoryReports.isEmpty, total > 0 else {
            view?.showEmptyState(message: "No expenses for this month.")
            return
        }

        let sliceViewData = makeSliceViewData(from: categoryReports)
        let totalText = currencyFormatter.string(from: NSNumber(value: total)) ?? "$0"
        view?.updateReport(slices: sliceViewData, totalText: totalText)

        updateHero()
    }
}

// MARK: - Builders

private extension ReportsPresenter {

    func makeSliceViewData(from reports: [CategoryReportData]) -> [ReportCategorySliceViewData] {
        return reports.map { report in
            let percentage = total == 0 ? 0 : (report.totalAmount / total)
            return ReportCategorySliceViewData(
                categoryName: report.categoryName,
                amount: report.totalAmount,
                amountText: currencyFormatter.string(from: NSNumber(value: report.totalAmount)) ?? "$0",
                percentageText: String(format: "%.0f%%", percentage * 100),
                color: UIColor(hex: report.colorHex ?? "") ?? .systemGray
            )
        }
    }

    func updateHero() {

        let monthFormatter = DateFormatter()
        monthFormatter.dateFormat = "MMMM yyyy"

        let monthTitle = monthFormatter.string(from: selectedMonth)
        let totalText = currencyFormatter.string(from: NSNumber(value: total)) ?? "$0"

        var changeText: String?
        var changeColor: UIColor?

        if let prev = previousMonthTotal, prev > 0 {
            let diff = total - prev
            let percent = (diff / prev) * 100
            let arrow = diff >= 0 ? "▲" : "▼"

            changeText = String(format: "%@ %.0f%% from last month", arrow, abs(percent))
            changeColor = diff >= 0 ? .systemRed : .systemGreen
        }

        view?.updateHeroCard(
            monthTitle: monthTitle,
            totalText: totalText,
            changeText: changeText,
            changeColor: changeColor
        )
    }

    func updateMonthUI() {

        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"

        let title = formatter.string(from: selectedMonth)
        let currentMonth = normalizedMonth(from: Date())
        let isNextEnabled = selectedMonth < currentMonth

        view?.updateMonth(
            title: title,
            date: selectedMonth,
            isPreviousEnabled: true,
            isNextEnabled: isNextEnabled
        )
    }

    func normalizedMonth(from date: Date) -> Date {
        calendar.date(from: calendar.dateComponents([.year, .month], from: date)) ?? date
    }
}
