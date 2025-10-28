//
//  TravelTabView.swift
//  KoalaCash
//
//  Created by Jesus Cedillo on 28/10/25.
//

import SwiftUI
import SwiftData

struct TravelTabView: View {
    @EnvironmentObject var sessionManager: SessionManager
    @Environment(\.modelContext) private var modelContext

    @StateObject private var viewModel = TravelTabViewModel()
    @State private var path: [TravelPaths] = []

    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                BackgroundView()

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        
                        HStack {
                            Spacer()
                            if viewModel.activeTrip != nil {
                                Button {
                                    path.append(.addTrip)
                                } label: {
                                    Image("KoalaCashTraveller")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 180)
                                        .accessibilityHidden(true)
                                }
                                .buttonStyle(.plain)
                                .accessibilityLabel("Agregar viaje")
                            } else {
                                Image("KoalaCashTraveller")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 180)
                                    .accessibilityHidden(true)
                            }
                            Spacer()
                        }

                        if let active = viewModel.activeTrip {
                            ActiveTripCard(summary: active,
                                           onTap: {
                                               path.append(.tripDetail(active.id))
                                           },
                                           onDelete: {
                                               viewModel.pendingDeleteID = active.id
                                               viewModel.showDeleteAlert = true
                                           })
                            .padding(.horizontal)
                        }

                        if viewModel.trips.isEmpty {
                            Text("Aún no tienes viajes registrados. ¡Crea uno nuevo!")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .padding(.horizontal)
                        } else {
                            LazyVStack(spacing: 16) {
                                ForEach(viewModel.trips.filter { !$0.isActive }) { trip in
                                    TripRowView(trip: trip,
                                                onTap: {
                                                    path.append(.tripDetail(trip.id))
                                                },
                                                onDelete: {
                                                    viewModel.pendingDeleteID = trip.id
                                                    viewModel.showDeleteAlert = true
                                                })
                                    .padding(.horizontal)
                                }
                            }
                        }

                        Spacer(minLength: 32)
                    }
                }
            }
            .navigationTitle("Viajes")
            .navigationBarTitleDisplayMode(.automatic)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if let active = viewModel.activeTrip {
                        Button {
                            path.append(.addTripExpense(active.id))
                        } label: {
                            Image(systemName: "plus")
                        }
                    } else {
                        Button {
                            path.append(.addTrip)
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
            .navigationDestination(for: TravelPaths.self) { value in
                switch value {
                case .addTrip:
                    AddTripView(path: $path)
                case .tripDetail(let id):
                    TripDetailView(tripID: id, path: $path)
                case .addTripExpense(let id):
                    AddTripExpenseView(tripID: id, path: $path)
                }
            }
        }
        .onAppear {
            viewModel.update(using: sessionManager.storedUser)
        }
        .onReceive(sessionManager.$storedUser) { user in
            viewModel.update(using: user)
        }
        .alert("¿Eliminar viaje?", isPresented: $viewModel.showDeleteAlert) {
            Button("Cancelar", role: .cancel) {}
            Button("Eliminar", role: .destructive) {
                Task {
                    await viewModel.deleteTrip(context: modelContext, user: sessionManager.storedUser)
                    sessionManager.reloadStoredUser()
                }
            }
        } message: {
            Text("Esta acción no se puede deshacer")
        }
    }
}

private struct ActiveTripCard: View {
    let summary: TravelTabViewModel.ActiveTripSummary
    var onTap: () -> Void
    var onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(summary.title)
                    .font(.title3.bold())
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)

                Label("Activo", systemImage: "airplane.circle.fill")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.mintTeal.opacity(0.2))
                    .foregroundColor(.mintTeal)
                    .clipShape(Capsule())
                    .lineLimit(1)
                    .fixedSize()

                Spacer()

                Menu {
                    Button(role: .destructive, action: onDelete) {
                        Label("Eliminar viaje", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .imageScale(.large)
                        .padding(4)
                        .contentShape(Rectangle())
                }
                .foregroundStyle(.secondary)
                .accessibilityLabel("Más opciones del viaje")
            }

            if !summary.dateRange.isEmpty {
                Text(summary.dateRange)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
            }

            MetricRow(
                baseLabel: "Total en \(summary.baseCurrencyCode)",
                baseAmount: summary.baseAmount,
                showConverted: summary.showsUserAmount && summary.userAmount != nil && summary.userCurrencyCode != nil,
                convertedLabel: "Total en \(summary.userCurrencyCode ?? "")",
                convertedAmount: summary.userAmount
            )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.thinMaterial)
        .cornerRadius(12)
        .contentShape(RoundedRectangle(cornerRadius: 12))
        .onTapGesture(perform: onTap)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
    }
}

private struct MetricRow: View {
    let baseLabel: String
    let baseAmount: String
    let showConverted: Bool
    let convertedLabel: String
    let convertedAmount: String?

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 16) {

            VStack(alignment: .leading, spacing: 2) {
                Text(baseLabel)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

                Text(baseAmount)
                    .font(.title2)
                    .monospacedDigit()
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                    .layoutPriority(2)
            }

            Spacer(minLength: 12)

            if showConverted, let convertedAmount {
                VStack(alignment: .trailing, spacing: 2) {
                    Text(convertedLabel)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)

                    Text(convertedAmount)
                        .font(.headline)
                        .monospacedDigit()
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                }
                .layoutPriority(1)
            }
        }
    }
}

private struct TripRowView: View {
    let trip: TravelTabViewModel.TripItem
    var onTap: () -> Void
    var onDelete: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(trip.name)
                            .font(.headline)
                        if trip.isActive {
                            Label("Activo", systemImage: "airplane.circle.fill")
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.mintTeal.opacity(0.2))
                                .foregroundColor(.mintTeal)
                                .clipShape(Capsule())
                        }
                    }
                    Text(trip.dateRange)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Gastado")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(trip.totalSpent)
                        .font(.headline)
                }
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .padding(.leading, 8)
            }
            .padding()
            .background(.thinMaterial)
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
        .contextMenu {
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Eliminar", systemImage: "trash")
            }
        }
    }
}

#Preview {
    NavigationStack {
        TravelTabView()
            .environmentObject(SessionManager(context: try! ModelContainer(for: StoredUser.self, Trip.self, TravelExpense.self).mainContext))
    }
}
