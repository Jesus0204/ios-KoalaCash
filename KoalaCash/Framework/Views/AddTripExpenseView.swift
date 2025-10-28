//
//  AddTripExpenseView.swift
//  KoalaCash
//
//  Created by Jesus Cedillo on 28/10/25.
//

import SwiftUI
import SwiftData

struct AddTripExpenseView: View {
    let tripID: String
    @Binding var path: [TravelPaths]

    @EnvironmentObject var sessionManager: SessionManager
    @Environment(\.modelContext) private var modelContext

    @StateObject private var viewModel = AddTripExpenseViewModel()
    @State private var trip: Trip?

    private let currencyOptions = ["MXN", "USD", "EUR", "AUD", "NZD"]
    private let categoryOptions = ["Comidas", "Transporte", "Avión", "Hospedaje", "Actividades", "Compras", "Souvenirs", "Datos móviles", "Otros"]

    var body: some View {
        ZStack {
            BackgroundView()

            if let trip {
                ScrollView {
                    VStack {
                        TitleSubtitleView(title: "\(trip.name): Nuevo gasto",
                                          subtitle: "Registra los gastos del viaje y lleva el control del total gastado")
                        
                        HStack {
                            Spacer()
                            Image("addExpenseKoala")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 180)
                                .accessibilityHidden(true)
                            Spacer()
                        }

                        DropdownField(label: "Moneda del gasto",
                                      options: currencyOptions,
                                      selectedOption: $viewModel.currencyValue,
                                      title: true)

                        MoneyField(
                            label: "Monto del gasto",
                            amount: $viewModel.amountValue,
                            currencyCode: viewModel.currencyValue,
                            title: true,
                            placeholder: "0.00",
                            showsSymbol: true,
                            maximumFractionDigits: 2,
                            allowsNegative: false
                        )

                        VStack(alignment: .leading) {
                            Text("Nombre del gasto")
                                .font(.title3)
                                .bold()

                            NoAccessoryTextField(text: $viewModel.nameValue,
                                                 placeholder: "Ingresa un nombre")
                                .padding()
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                                )
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 8)

                        DropdownField(label: "Categoría del gasto",
                                      options: categoryOptions,
                                      selectedOption: $viewModel.categoryValue,
                                      title: true)
                        .padding(.bottom, 8)

                        Toggle("Gasto compartido", isOn: $viewModel.isShared)
                            .padding(.horizontal, 24)
                            .padding(.bottom, 8)

                        if viewModel.isShared {
                            Stepper("Número de personas: \(viewModel.sharedCount)",
                                    value: $viewModel.sharedCount,
                                    in: 2...10)
                            .padding(.horizontal, 24)
                            .padding(.bottom, 24)
                            .padding(.top, 16)
                        }
                        
                        Toggle("Contar dentro del presupuesto", isOn: $viewModel.includeInBudget)
                            .padding(.horizontal, 24)
                            .padding(.bottom, 24)

                        CustomButton(
                            text: "Guardar gasto",
                            action: {
                                guard let currentTrip = self.trip else { return }
                                Task {
                                    await viewModel.guardarGasto(trip: currentTrip, context: modelContext)
                                    if !viewModel.showAlert {
                                        path.removeLast()
                                        sessionManager.reloadStoredUser()
                                    }
                                }
                            },
                            backgroundColor: .black,
                            foregroundColor: .white
                        )
                    }
                }
            } else {
                VStack(spacing: 12) {
                    ProgressView()
                    Text("Cargando viaje...")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .onAppear {
            fetchTrip()
        }
        .onTapGesture { UIApplication.shared.hideKeyboard()
        }
        .alert(isPresented: $viewModel.showAlert) {
            Alert(title: Text("Oops!"), message: Text(viewModel.messageAlert))
        }
    }

    private func fetchTrip() {
        guard let uuid = UUID(uuidString: tripID) else { return }
        let descriptor = FetchDescriptor<Trip>(predicate: #Predicate { $0.tripID == uuid })
        if let fetched = try? modelContext.fetch(descriptor).first {
            trip = fetched
            viewModel.currencyValue = fetched.baseCurrency
        } else if let stored = sessionManager.storedUser?.trips.first(where: { $0.tripID == uuid }) {
            trip = stored
            viewModel.currencyValue = stored.baseCurrency
        }
    }
}

struct AddTripExpenseView_Previews: PreviewProvider {
    @State static var path: [TravelPaths] = []

    static var previews: some View {
        AddTripExpenseView(tripID: UUID().uuidString, path: $path)
    }
}
