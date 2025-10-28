//
//  TripDetailView.swift
//  KoalaCash
//
//  Created by Jesus Cedillo on 28/10/25.
//

import SwiftUI
import SwiftData

struct TripDetailView: View {
    let tripID: String
    @Binding var path: [TravelPaths]

    @EnvironmentObject var sessionManager: SessionManager
    @Environment(\.modelContext) private var modelContext

    @StateObject private var viewModel = TripDetailViewModel()

    var body: some View {
        ZStack {
            BackgroundView()

            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(viewModel.tripName)
                        .font(.largeTitle.bold())
                    if !viewModel.dateRange.isEmpty {
                        Text(viewModel.dateRange)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    Text("Total gastado")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text(viewModel.totalSpentText)
                        .font(.title2.bold())
                }
                .padding(.horizontal)
                .padding(.top, 16)

                if viewModel.expenses.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("No hay gastos registrados para este viaje.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Text("Agrega el primer gasto usando el botón superior derecho.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal)
                } else {
                    List {
                        ForEach(viewModel.expenses) { expense in
                            TripExpenseRow(expense: expense)
                                .listRowBackground(Color.clear)
                                .contextMenu {
                                    Button(role: .destructive) {
                                        viewModel.pendingDeleteExpenseID = expense.id
                                        viewModel.showDeleteAlert = true
                                    } label: {
                                        Label("Eliminar", systemImage: "trash")
                                    }
                                }
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }

                Spacer()
            }
        }
        .navigationTitle("Detalle del viaje")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    path.append(.addTripExpense(tripID))
                } label: {
                    Image(systemName: "plus")
                }
                .disabled(viewModel.tripName.isEmpty)
            }
        }
        .onAppear {
            viewModel.update(using: sessionManager.storedUser, tripID: tripID)
        }
        .onReceive(sessionManager.$storedUser) { user in
            viewModel.update(using: user, tripID: tripID)
        }
        .alert("¿Eliminar gasto?", isPresented: $viewModel.showDeleteAlert) {
            Button("Cancelar", role: .cancel) {}
            Button("Eliminar", role: .destructive) {
                Task {
                    await viewModel.deleteExpense(context: modelContext, user: sessionManager.storedUser, tripID: tripID)
                    sessionManager.reloadStoredUser()
                }
            }
        } message: {
            Text("Esta acción no se puede deshacer")
        }
    }
}

private struct TripExpenseRow: View {
    let expense: TripDetailViewModel.ExpenseItem

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(expense.name)
                    .font(.headline)
                Text(expense.category)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text(expense.date, format: .dateTime.day().month(.abbreviated))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                if expense.dividedBy > 1 {
                    Text("Dividido entre \(expense.dividedBy)")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Text("Total: \(expense.totalOriginalAmount)")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
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

struct TripDetailView_Previews: PreviewProvider {
    @State static var path: [TravelPaths] = []

    static var previews: some View {
        TripDetailView(tripID: UUID().uuidString, path: $path)
    }
}
