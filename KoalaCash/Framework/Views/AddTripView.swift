//
//  AddTripView.swift
//  KoalaCash
//
//  Created by Jesus Cedillo on 28/10/25.
//

import SwiftUI
import SwiftData

struct AddTripView: View {
    @EnvironmentObject var sessionManager: SessionManager
    @Environment(\.modelContext) private var modelContext

    @StateObject private var viewModel = AddTripViewModel()
    @Binding var path: [TravelPaths]

    @State private var hasEndDate: Bool = false

    private let currencyOptions = ["MXN", "USD", "EUR", "AUD", "NZD"]

    private var today: Date { Date() }
    private var minDate: Date {
        Calendar.current.date(byAdding: .month, value: -6, to: today) ?? today
    }
    private var maxDate: Date {
        Calendar.current.date(byAdding: .year, value: 2, to: today) ?? today
    }
    private var endMinDate: Date {
        max(viewModel.startDate, minDate)
    }

    var body: some View {
        ZStack {
            BackgroundView()

            ScrollView {
                VStack {
                    TitleSubtitleView(title: "Nuevo viaje", subtitle: "Registra un viaje para llevar control de sus gastos")
                    
                    HStack {
                        Spacer()
                        Image("KoalaCashAddTrip")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 180)
                            .accessibilityHidden(true)
                        Spacer()
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Nombre del viaje")
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
                    
                    VStack(alignment: .leading) {
                        Text("Fecha de inicio")
                            .font(.title3)
                            .bold()
                        
                        DatePicker(
                            "Inicio",
                            selection: $viewModel.startDate,
                            in: minDate...maxDate,
                            displayedComponents: .date
                        )
                        .datePickerStyle(.compact)
                        .labelsHidden()
                        .padding()
                        .cornerRadius(10)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 8)
                    
                    Toggle("Definir fecha de fin", isOn: $hasEndDate.animation())
                        .padding(.horizontal, 24)
                        .padding(.bottom, 8)
                    
                    if hasEndDate {
                        VStack(alignment: .leading) {
                            Text("Fecha de fin")
                                .font(.title3)
                                .bold()
                            
                            DatePicker(
                                "Fin",
                                selection: Binding(
                                    get: { viewModel.endDate ?? endMinDate },
                                    set: { viewModel.endDate = $0 }
                                ),
                                in: endMinDate...maxDate,
                                displayedComponents: .date
                            )
                            .datePickerStyle(.compact)
                            .labelsHidden()
                            .padding()
                            .cornerRadius(10)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 24)
                        .padding(.bottom, 8)
                    }
                    
                    DropdownField(label: "Moneda base",
                                  options: currencyOptions,
                                  selectedOption: $viewModel.currencyValue,
                                  title: true)
                    
                    CustomButton(
                        text: "Guardar viaje",
                        action: {
                            guard let user = sessionManager.storedUser else { return }
                            Task {
                                await viewModel.guardarViaje(usuario: user, context: modelContext)
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
        }
        .onAppear {
            if let user = sessionManager.storedUser {
                viewModel.currencyValue = user.currencyValue
            }
            // Clamp initial startDate within bounds
            if viewModel.startDate < minDate { viewModel.startDate = minDate }
            if viewModel.startDate > maxDate { viewModel.startDate = maxDate }
        }
        .onChange(of: hasEndDate) {
            if !hasEndDate {
                viewModel.endDate = nil
            } else {
                // When enabling end date, ensure it starts at a valid minimum
                if let end = viewModel.endDate {
                    if end < endMinDate { viewModel.endDate = endMinDate }
                    if end > maxDate { viewModel.endDate = maxDate }
                } else {
                    viewModel.endDate = endMinDate
                }
            }
        }
        .onChange(of: viewModel.startDate) { _, newStart in
            // Keep startDate within global bounds
            var adjusted = newStart
            if adjusted < minDate { adjusted = minDate }
            if adjusted > maxDate { adjusted = maxDate }
            if adjusted != viewModel.startDate {
                viewModel.startDate = adjusted
            }
            // If we have an endDate, keep it valid relative to new start
            if let end = viewModel.endDate {
                if end < endMinDate { viewModel.endDate = endMinDate }
                if end > maxDate { viewModel.endDate = maxDate }
            }
        }
        .onTapGesture { UIApplication.shared.hideKeyboard()
        }
        .alert(isPresented: $viewModel.showAlert) {
            Alert(title: Text("Oops!"), message: Text(viewModel.messageAlert))
        }
    }
}

struct AddTripView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapper()
    }

    struct PreviewWrapper: View {
        @State var path: [TravelPaths] = []

        var body: some View {
            AddTripView(path: $path)
        }
    }
}
