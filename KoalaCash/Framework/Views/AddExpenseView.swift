//
//  AddExpenseView.swift
//  KoalaCash
//
//  Created by Jesus Cedillo on 31/07/25.
//

import SwiftUI

struct AddExpenseView: View {
    @State private var currencyValue : String = "MXN"
    @State private var categoryValue : String = "Renta"
    @State private var budgetValue : Decimal? = nil
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
                    
                    DropdownField(label: "Moneda del gasto", options: ["MXN", "AUD", "USD", "EUR" ], selectedOption: $currencyValue, title: true)
                    
                    MoneyField(
                                label: "Monto del gasto",
                                amount: $budgetValue,
                                currencyCode: currencyValue,
                                title: true,
                                placeholder: "0.00",
                                showsSymbol: true,
                                maximumFractionDigits: 2,
                                allowsNegative: false
                            )
                    
                    DropdownField(label: "Categoría del gasto", options: ["Renta", "Supermercado", "Transporte", "Lavandería", "Comidas en restaurante", "Datos móviles", "Entretenimiento", "Cine" ], selectedOption: $categoryValue, title: true)
                }
            }
            
            VStack {
                Spacer()
                CustomButton(
                    text: "Guardar gasto",
                    action: { },
                    backgroundColor: .black,
                    foregroundColor: .white
                )
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
        }
    }
}

#Preview {
    AddExpenseView()
}
