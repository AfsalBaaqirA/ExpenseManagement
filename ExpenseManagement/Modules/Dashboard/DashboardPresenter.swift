//
//  DashboardPresenter.swift
//  ExpenseManagement
//
//  Created by Afsal Baaqir A on 14/02/26.
//


import Foundation

final class DashboardPresenter: DashboardPresenterProtocol, DashboardInteractorOutputProtocol {
    weak var view: DashboardViewProtocol?
    var interactor: DashboardInteractorInputProtocol?
    var router: DashboardRouterProtocol?

    func viewDidLoad() {
        interactor?.generateSampleDataIfNeeded()
        interactor?.fetchExpenses()
    }

    func refreshData() {
        interactor?.fetchExpenses()
    }

    func didSelectSeeAll() {
        router?.navigateToAllExpenses()
    }

    func didUpdateIncome(_ income: Double) {
        interactor?.updateIncome(income)
    }

    func didConfirmPopulateSampleData() {
        interactor?.populateSampleData()
        interactor?.fetchExpenses()
    }

    func didFetchExpenses(_ expenses: [Expense], incomeAmount: Double) {
        view?.showExpenses(expenses)

        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.year, .month], from: now)
        guard let monthStart = calendar.date(from: components) else {
            view?.updateSummary(
                income: formatCurrency(0),
                expenses: formatCurrency(0),
                savings: formatCurrency(0)
            )
            return
        }

        let nextMonthStart = calendar.date(byAdding: DateComponents(month: 1), to: monthStart) ?? now

        let thisMonthExpenses = expenses.filter { expense in
            let date = expense.safeDate
            return date >= monthStart && date < nextMonthStart
        }

        let monthExpenseAmount = thisMonthExpenses.reduce(0.0) { $0 + $1.safeAmount }
        let savingsAmount = incomeAmount - monthExpenseAmount

        let incomeFormatted = formatCurrency(incomeAmount)
        let expensesFormatted = formatCurrency(monthExpenseAmount)
        let savingsFormatted = formatCurrency(savingsAmount)

        view?.updateSummary(
            income: incomeFormatted,
            expenses: expensesFormatted,
            savings: savingsFormatted
        )
    }

    func didFailToFetchExpenses(with error: Error) {
        view?.showError("Failed to fetch expenses: \(error.localizedDescription)")
    }

    func shouldAskToPopulateSampleData() {
        view?.askToPopulateSampleData()
    }

    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "$0"
    }
}
