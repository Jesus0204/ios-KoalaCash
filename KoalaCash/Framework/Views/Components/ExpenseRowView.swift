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
            }
            Spacer()
            VStack(alignment: .trailing) {
                Text(expense.originalAmount)
                    .font(.subheadline)
                Text(expense.convertedAmount)
                    .font(.caption)
                    .foregroundStyle(expense.isFrozen ? .secondary : .primary)
            }
            if expense.isFrozen {
                Image(systemName: "snowflake")
                    .foregroundStyle(.blue)
                    .padding(.leading, 4)
            }
        }
        .padding(.vertical, 8)
    }
}
