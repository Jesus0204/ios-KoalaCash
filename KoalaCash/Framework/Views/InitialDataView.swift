//
//  InitialDataView.swift
//  KoalaCash
//
//  Created by Jesus Cedillo on 29/07/25.
//

import SwiftUI

struct InitialDataView: View {
    @Binding var path: [SessionPaths]
    
    @ObservedObject var onboardingViewModel = OnboardingViewModel()
    
    var body: some View {
        ZStack {
            BackgroundView()
            
            ScrollView {
                VStack() {
                    TitleSubtitleView(title: "¡Comenzemos!", subtitle: "Configura tu quincena y moneda base. Podrás cambiarlos en Ajustes.")
                    
                    HStack {
                        Spacer()
                        Image("Onboarding_Koala")
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
            
            VStack {
                Spacer()
                CustomButton(
                    text: "Guardar y seguir",
                    action: {
                        onboardingViewModel.validarDatosApp()
                        
                        if !onboardingViewModel.showAlert {
                            path.append(.accountDetails)
                        }
                    },
                    backgroundColor: .black,
                    foregroundColor: .white
                )
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
        }
        .onTapGesture {
            UIApplication.shared.hideKeyboard()
        }
        .alert(isPresented: $onboardingViewModel.showAlert) {
            Alert(
                title: Text("Oops!"),
                message: Text(onboardingViewModel.messageAlert)
            )
        }
    }
}

struct InitialDataView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapper()
    }

    struct PreviewWrapper: View {
        @State var path: [SessionPaths] = []

        var body: some View {
            InitialDataView(path: $path)
        }
    }
}
