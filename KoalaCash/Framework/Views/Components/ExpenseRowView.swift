//
//  ExpenseRowView.swift
//  KoalaCash
//
//  Created by Jesus Cedillo on 31/07/25.
//

import SwiftUI

struct ExpenseRowView: View {
    let expense: DashboardViewModel.ExpenseSummary
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(expense.name)
                    .font(.headline)
                Text(expense.category)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text(expense.date, format: .dateTime.day().month(.abbreviated))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                if expense.excludedFromBudget {
                    BudgetBadge()
                        .transition(.scale.combined(with: .opacity))
                        .animation(.snappy(duration: 0.2), value: expense.excludedFromBudget)
                }
            }
            Spacer()
            VStack(alignment: .trailing) {
                Text(expense.originalAmount)
                    .font(.subheadline)
                Text(expense.convertedAmount)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                if expense.dividedBy > 1 {
                    Text("Total: \(expense.totalOriginalAmount)")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            if expense.dividedBy > 1 {
                Image(systemName: "person.2.fill")
                    .foregroundStyle(.blue)
                    .padding(.leading, 4)
            }
        }
        .padding(.vertical, 8)
    }
}
