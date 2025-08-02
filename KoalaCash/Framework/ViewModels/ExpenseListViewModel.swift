//
//  ExpenseListViewModel.swift
//  KoalaCash
//
//  Created by Jesus Cedillo on 02/08/25.
//

import Foundation
import SwiftUI

class ExpensesListViewModel: ObservableObject {
    struct ExpenseItem: Identifiable {
        let id: String
        let name: String
        let category: String
        let date: Date
        let originalAmount: String
        let convertedAmount: String
    }

    struct MonthSection: Identifiable {
        var id: String { month }
        let month: String
        let expenses: [ExpenseItem]
    }

    @Published var sections: [MonthSection] = []

    func update(using user: StoredUser?) {
        guard let user else {
            sections = []
            return
        }

        var allExpenses: [Expense] = []
        for q in user.quincenas {
            allExpenses.append(contentsOf: q.expenses)
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL yyyy"

        let items = allExpenses.map { exp in
            ExpenseItem(
                id: exp.expenseID.uuidString,
                name: exp.name,
                category: exp.category,
                date: exp.datePurchase,
                originalAmount: format(amount: exp.originalAmount, code: exp.originalCurrency),
                convertedAmount: format(amount: exp.convertedAmount, code: exp.convertedCurrency)
            )
        }.sorted { $0.date > $1.date }

        let grouped = Dictionary(grouping: items) { item in
            formatter.string(from: item.date)
        }

        sections = grouped.keys.sorted { formatter.date(from: $0)! > formatter.date(from: $1)! }.map { key in
            MonthSection(month: key, expenses: grouped[key] ?? [])
        }
    }

    private func format(amount: Decimal, code: String) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = code
        formatter.maximumFractionDigits = 2
        let number = NSDecimalNumber(decimal: amount)
        return formatter.string(from: number) ?? "\(code) \(number)"
    }
}
