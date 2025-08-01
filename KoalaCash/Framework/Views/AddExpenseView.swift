//
//  AddExpenseView.swift
//  KoalaCash
//
//  Created by Jesus Cedillo on 31/07/25.
//

import SwiftUI
import SwiftData

struct AddExpenseView: View {
    @StateObject private var addExpenseViewModel = AddExpenseViewModel()
    
    @Binding var path: [DashboardPaths]
    
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var sessionManager: SessionManager
    
    var body: some View {
        ZStack {
            BackgroundView()
            
            ScrollView {
                VStack {
                    TitleSubtitleView(title: "¡Agrega un nuevo gasto!", subtitle: "Este gasto se actualizará con la tasa del día hasta que lo marques como ‘Pagado’.")
                    
                    HStack {
                        Spacer()
                        Image("addExpenseKoala")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 180)
                            .accessibilityHidden(true)
                        Spacer()
                    }
                    
                    DropdownField(label: "Moneda del gasto", options: ["MXN", "AUD", "USD", "EUR" ], selectedOption: $addExpenseViewModel.currencyValue, title: true)
                    
                    MoneyField(
                                label: "Monto del gasto",
                                amount: $addExpenseViewModel.budgetValue,
                                currencyCode: addExpenseViewModel.currencyValue,
                                title: true,
                                placeholder: "0.00",
                                showsSymbol: true,
                                maximumFractionDigits: 2,
                                allowsNegative: false
                            )
                    
                    DropdownField(label: "Categoría del gasto", options: ["Renta", "Supermercado", "Transporte", "Lavandería", "Comidas en restaurante", "Datos móviles", "Entretenimiento", "Cine" ], selectedOption: $addExpenseViewModel.categoryValue, title: true)
                }
            }
            
            VStack {
                Spacer()
                CustomButton(
                    text: "Guardar gasto",
                    action: {
                        if let user = sessionManager.storedUser {
                            Task {
                                await addExpenseViewModel.guardarGasto(usuario: user, context: modelContext)
                                if !addExpenseViewModel.showAlert {
                                    sessionManager.reloadStoredUser()
                                    path.removeLast()
                                }
                            }
                        }
                    },
                    backgroundColor: .black,
                    foregroundColor: .white
                )
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
        }
        .onTapGesture { UIApplication.shared.hideKeyboard()
        }
        .alert(isPresented: $addExpenseViewModel.showAlert) {
            Alert(
                title: Text("Oops!"),
                message: Text(addExpenseViewModel.messageAlert)
            )
        }
    }
}

struct AddExpenseView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapper()
    }

    struct PreviewWrapper: View {
        @State var path: [DashboardPaths] = []

        var body: some View {
            AddExpenseView(path: $path)
        }
    }
}
