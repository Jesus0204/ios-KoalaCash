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
                Text(expense.title)
                    .font(.headline)
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
                    .foregroundStyle(expense.isPaid ? .secondary : .primary)
            }
        }
        .padding(.vertical, 8)
    }
}
