//
//  SettingsView.swift
//  KoalaCash
//
//  Created by Jesus Cedillo on 31/07/25.
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var onboardingViewModel = OnboardingViewModel()
    
    var body: some View {
        ZStack {
            BackgroundView()
            
            ScrollView {
                VStack {
                    TitleSubtitleView(title: "Ajustes", subtitle: "Aquí puedes ajustar tu fecha de depósito, la moneda principal y tu presupuesto de quincena.")
                        .padding(.bottom, 14)
                    
                    HStack {
                        Spacer()
                        Image("koala_Settings")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 180)
                            .accessibilityHidden(true)
                        Spacer()
                    }
                    
                    FechaPicker(label: "Fecha de tu próximo depósito", selectedDate: $onboardingViewModel.fortnightDate, title: true)
                    
                    DropdownField(label: "Moneda principal", options: ["MXN", "AUD", "USD", "EUR" ], selectedOption: $onboardingViewModel.currencyValue, title: true)
                    
                    MoneyField(
                                label: "Quincena",
                                amount: $onboardingViewModel.budgetValue,
                                currencyCode: onboardingViewModel.currencyValue,
                                title: true,
                                placeholder: "0.00",
                                showsSymbol: true,
                                maximumFractionDigits: 2,
                                allowsNegative: false
                            )
                }
            }
        }
    }
}

#Preview {
    SettingsView()
}
