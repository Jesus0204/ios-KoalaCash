//
//  DashboardViewModel.swift
//  KoalaCash
//
//  Created by Jesus Cedillo on 01/08/25.
//

import Foundation
import SwiftUI

class DashboardViewModel: ObservableObject {
    @Published var spentUserCurrency: Decimal = 0
    @Published var budgetUserCurrency: Decimal = 0
    @Published var originalBudgetUserCurrency: Decimal = 0
    @Published var daysUntilNextDeposit: Int = 0
    @Published var noExpensesMessage: String? = nil
    @Published var userCurrencyCode: String = "MXN"
    
    private let exclusionStore: ExpenseExclusionStore

    init(exclusionStore: ExpenseExclusionStore = .shared) {
        self.exclusionStore = exclusionStore
    }
    
    var spentUserCurrencyText: String {
        format(amount: spentUserCurrency, code: userCurrencyCode)
    }

    var budgetUserCurrencyText: String {
        format(amount: budgetUserCurrency, code: userCurrencyCode)
    }
    
    var remainingPercentage: Double {
        let budget = NSDecimalNumber(decimal: budgetUserCurrency).doubleValue
        guard budget > 0 else { return 0 }
        let spent = NSDecimalNumber(decimal: spentUserCurrency).doubleValue
        return (1 - spent / budget) * 100
    }
    
    var isOverBudget: Bool {
        NSDecimalNumber(decimal: spentUserCurrency).doubleValue > NSDecimalNumber(decimal: budgetUserCurrency).doubleValue
    }
    
    var progressTotal: Double {
        NSDecimalNumber(decimal: budgetUserCurrency).doubleValue
    }
    
    var progressValue: Double {
        let spent = NSDecimalNumber(decimal: spentUserCurrency).doubleValue
        let budget = NSDecimalNumber(decimal: budgetUserCurrency).doubleValue
        if spent > budget {
            return min(spent - budget, budget)
        } else {
            return spent
        }
    }

    struct CategoryData: Identifiable {
        var id: String { name }
        let name: String
        let amountMXN: Double
    }
    
    @Published var categoryData: [CategoryData] = []

    struct ExpenseSummary: Identifiable {
        let id: String
        let name: String
        let category: String
        let date: Date
        let originalAmount: String
        let convertedAmount: String
        let dividedBy: Int
        let totalOriginalAmount: String
        let excludedFromBudget: Bool
    }
    @Published var recentExpenses: [ExpenseSummary] = []

    func update(using user: StoredUser?) {
        guard let user else {
            spentUserCurrency = 0
            budgetUserCurrency = 0
            daysUntilNextDeposit = 0
            categoryData = []
            recentExpenses = []
            noExpensesMessage = "No hay gastos para esta quincena."
            userCurrencyCode = "MXN"
            return
        }
        
        userCurrencyCode = user.currencyValue
        originalBudgetUserCurrency = user.budgetValue

        let calendar = Calendar.current
        daysUntilNextDeposit = calendar.dateComponents([.day], from: Date(), to: user.fortnightDate).day ?? 0

        if let quincena = user.quincenas.first(where: { $0.active }) {
            spentUserCurrency = quincena.spent
            budgetUserCurrency = quincena.budgetAmount
            
            let expenses = quincena.expenses.sorted { $0.datePurchase > $1.datePurchase }
            if expenses.isEmpty {
                noExpensesMessage = "No hay gastos para esta quincena."
                categoryData = []
                recentExpenses = []
            } else {
                noExpensesMessage = nil
                var totals: [String: Decimal] = [:]
                for exp in expenses {
                    if exp.category == "Renta" { continue }
                    if exclusionStore.isExcluded(exp.expenseID) { continue }
                    totals[exp.category, default: 0] += exp.convertedAmount
                }
                categoryData = totals.map {
                    CategoryData(name: $0.key, amountMXN: NSDecimalNumber(decimal: $0.value).doubleValue)
                }

                recentExpenses = expenses.prefix(5).map { exp in
                    let isExcluded = exclusionStore.isExcluded(exp.expenseID)
                    return ExpenseSummary(
                        id: exp.expenseID.uuidString,
                        name: exp.name,
                        category: exp.category,
                        date: exp.datePurchase,
                        originalAmount: format(amount: exp.originalAmount, code: exp.originalCurrency),
                        convertedAmount: format(amount: exp.convertedAmount, code: exp.convertedCurrency),
                        dividedBy: exp.dividedBy,
                        totalOriginalAmount: format(amount: exp.totalOriginalAmount, code: exp.originalCurrency),
                        excludedFromBudget: isExcluded
                    )
                }
            }
        } else {
            spentUserCurrency = 0
            budgetUserCurrency = user.budgetValue
            categoryData = []
            recentExpenses = []
            noExpensesMessage = "No hay gastos para esta quincena."
        }
    }
    
    private func format(amount: Decimal, code: String) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = code
        formatter.currencySymbol = code.currencySymbol
        formatter.maximumFractionDigits = 2
        let number = NSDecimalNumber(decimal: amount)
        return formatter.string(from: number) ?? "\(code.currencySymbol)\(number)"
    }
}
