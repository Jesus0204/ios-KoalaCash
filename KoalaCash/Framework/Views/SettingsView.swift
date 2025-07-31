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
                    TitleSubtitleView(title: "Ajustes", subtitle: "Personaliza depósito, moneda y presupuesto por quincena.")
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
                    .padding(.bottom, 24)
                    
                    VStack {
                        Spacer()
                        Button(
                            action: {}
                        ){
                            Text("Cerrar Sesión")
                                .underline()
                                .font(.system(.body, design: .rounded))
                                .foregroundColor(.black)
                        }
                        .padding(.bottom, 16)
                        .buttonStyle(PlainButtonStyle())
                    }
                    .ignoresSafeArea(.keyboard, edges: .bottom)
                }
            }
        }
        .onTapGesture {
            UIApplication.shared.hideKeyboard()
        }
    }
}

#Preview {
    SettingsView()
}
