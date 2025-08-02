//
//  ExpensesListView.swift
//  KoalaCash
//
//  Created by Jesus Cedillo on 02/08/25.
//

import SwiftUI
import SwiftData

struct ExpensesListView: View {
    @StateObject private var viewModel = ExpensesListViewModel()
    @EnvironmentObject var sessionManager: SessionManager
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        ZStack {
            BackgroundView()

            VStack(alignment: .leading, spacing: 0) {
                TitleSubtitleView(title: "Historial de gastos", subtitle: "")
                    .padding([.top, .horizontal])

                if viewModel.sections.isEmpty {
                    Text("No hay gastos registrados aún")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                }

                List {
                    ForEach(viewModel.sections) { section in
                        Section(header:
                            Text(section.month)
                                .font(.title3.bold())
                                .padding(.top, 8)
                        ) {
                            ForEach(section.expenses) { expense in
                                ExpenseDetailRowView(expense: expense)
                                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                        Button(role: .destructive) {
                                            viewModel.deleteID = expense.id
                                            viewModel.showDeleteAlert = true
                                        } label: {
                                            Label("Eliminar", systemImage: "trash")
                                        }
                                    }
                                    .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                        if !expense.isFrozen {
                                            Button {
                                                viewModel.freezeID = expense.id
                                                viewModel.showFreezeAlert = true
                                            } label: {
                                                Label("Congelar", systemImage: "snowflake")
                                            }
                                            .tint(.blue)
                                        }
                                    }
                                    .listRowBackground(Color.clear)
                            }
                        }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
        }
        .onAppear {
            viewModel.update(using: sessionManager.storedUser)
        }
        .onChange(of: sessionManager.storedUser) { _, newUser in
            viewModel.update(using: newUser)
        }
        .alert("¿Eliminar gasto?", isPresented: $viewModel.showDeleteAlert, actions: {
            Button("Cancelar", role: .cancel) {}
            Button("Eliminar", role: .destructive) {
                if let id = viewModel.deleteID {
                    Task {
                        await viewModel.eliminarGasto(id: id, user: sessionManager.storedUser, context: modelContext)
                        sessionManager.reloadStoredUser()
                    }
                }
            }
        }, message: {
            Text("Esta acción no se puede deshacer")
        })
        .alert("¿Congelar gasto?", isPresented: $viewModel.showFreezeAlert, actions: {
            Button("Cancelar", role: .cancel) {}
            Button("Congelar") {
                if let id = viewModel.freezeID {
                    Task {
                        await viewModel.congelarGasto(id: id, user: sessionManager.storedUser, context: modelContext)
                        sessionManager.reloadStoredUser()
                    }
                }
            }
        }, message: {
            Text("El gasto se marcará como congelado")
        })
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
            if expense.isFrozen {
                Image(systemName: "snowflake")
                    .foregroundStyle(.blue)
                    .padding(.leading, 4)
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    ExpensesListView()
}
