//
//  ExpensesListView.swift
//  KoalaCash
//
//  Created by Jesus Cedillo on 02/08/25.
//

import SwiftUI

struct ExpensesListView: View {
    @StateObject private var viewModel = ExpensesListViewModel()
    @EnvironmentObject var sessionManager: SessionManager

    var body: some View {
        ZStack {
            BackgroundView()

            ScrollView {
                VStack(alignment: .leading) {
                    TitleSubtitleView(title: "Historial de gastos", subtitle: "")
                        .padding(.bottom, 8)
                    
                    if viewModel.sections.isEmpty {
                        Text("No hay gastos registrados aún")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    ForEach(viewModel.sections) { section in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(section.month)
                                .font(.title3.bold())
                                .padding(.top, 8)
                            ForEach(section.expenses) { expense in
                                ExpenseDetailRowView(expense: expense)
                                    .background(Color.white.opacity(0.001))
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(.horizontal)
            }
        }
        .onAppear {
            viewModel.update(using: sessionManager.storedUser)
        }
        .onChange(of: sessionManager.storedUser) { _, newUser in
            viewModel.update(using: newUser)
        }
    }
}

struct ExpenseDetailRowView: View {
    let expense: ExpensesListViewModel.ExpenseItem

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
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
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    ExpensesListView()
}
