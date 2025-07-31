//
//  InitialDataView.swift
//  KoalaCash
//
//  Created by Jesus Cedillo on 29/07/25.
//

import SwiftUI

struct InitialDataView: View {
    @StateObject private var onboardingViewModel = OnboardingViewModel()
    
    var body: some View {
        ZStack {
            BackgroundView()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    TitleSubtitleView(title: "¡Comenzemos!", subtitle: "Te pediremos que nos de los datos necesarios para poder comenzar a trabajar con tu KoalaCash")
                    
                    FechaPicker(label: "Fecha de tu próximo depósito", selectedDate: $onboardingViewModel.fortnightDate, title: true)
                    
                    DropdownField(label: "Moneda principal", options: ["MXN", "AUD", "USD", "EUR" ], selectedOption: $onboardingViewModel.currencyValue, title: true)
                    
                    MoneyField(
                                label: "Monto",
                                amount: $onboardingViewModel.budgetValue,
                                currencyCode: "MXN",
                                title: true,
                                placeholder: "0.00",
                                showsSymbol: true,
                                maximumFractionDigits: 2,
                                allowsNegative: false
                            )
                }
            }
            
            VStack {
                Spacer()
                CustomButton(
                    text: "Continuar",
                    action: { },
                    backgroundColor: .black,
                    foregroundColor: .white
                )
            }
        }
        .onTapGesture {
            UIApplication.shared.hideKeyboard()
        }
    }
}

#Preview {
    InitialDataView()
}
