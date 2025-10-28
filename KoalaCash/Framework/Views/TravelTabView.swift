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
                            Image("KoalaCashTraveller")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 180)
                                .accessibilityHidden(true)
                            Spacer()
                        }

                        if let active = viewModel.activeTrip {
                            ActiveTripCard(summary: active)
                                .padding(.horizontal)
                        }

                        if viewModel.trips.isEmpty {
                            Text("Aún no tienes viajes registrados. ¡Crea uno nuevo!")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .padding(.horizontal)
                        } else {
                            LazyVStack(spacing: 16) {
                                ForEach(viewModel.trips) { trip in
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
                    Button {
                        path.append(.addTrip)
                    } label: {
                        Image(systemName: "plus")
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

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Viaje activo")
                .font(.headline)
                .foregroundStyle(.secondary)
            Text(summary.title)
                .font(.title2.bold())
            Text(summary.dateRange)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text(summary.amount)
                .font(.title3)
                .padding(.top, 8)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.thinMaterial)
        .cornerRadius(12)
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
