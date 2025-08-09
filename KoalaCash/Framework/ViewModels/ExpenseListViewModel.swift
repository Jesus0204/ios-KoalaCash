//
//  ExpenseListViewModel.swift
//  KoalaCash
//
//  Created by Jesus Cedillo on 02/08/25.
//

import Foundation
import SwiftUI
import SwiftData

class ExpensesListViewModel: ObservableObject {
    struct ExpenseItem: Identifiable {
        let id: String
        let name: String
        let category: String
        let date: Date
        let originalAmount: String
        let convertedAmount: String
        let dividedBy: Int
        let totalOriginalAmount: String
    }

    struct MonthSection: Identifiable {
        var id: String { month }
        let month: String
        let expenses: [ExpenseItem]
    }

    @Published var sections: [MonthSection] = []
    
    var deleteRequirement: DeleteExpenseRequirementProtocol

    init(deleteRequirement: DeleteExpenseRequirementProtocol = DeleteExpenseRequirement.shared) {
        self.deleteRequirement = deleteRequirement
    }
    
    @Published var showDeleteAlert = false
    @Published var deleteID: String? = nil

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
                convertedAmount: format(amount: exp.convertedAmount, code: exp.convertedCurrency),
                dividedBy: exp.dividedBy,
                totalOriginalAmount: format(amount: exp.totalOriginalAmount, code: exp.originalCurrency)
            )
        }.sorted { $0.date > $1.date }

        let grouped = Dictionary(grouping: items) { item in
            formatter.string(from: item.date)
        }

        sections = grouped.keys.sorted { formatter.date(from: $0)! > formatter.date(from: $1)! }.map { key in
            MonthSection(month: key, expenses: grouped[key] ?? [])
        }
    }
    
    @MainActor
    func eliminarGasto(id: String, user: StoredUser?, context: ModelContext) async {
        let eliminado = await deleteRequirement.eliminarGasto(expenseID: id, context: context)
        if eliminado {
            update(using: user)
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
