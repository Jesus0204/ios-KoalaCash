//
//  SettingsView.swift
//  KoalaCash
//
//  Created by Jesus Cedillo on 31/07/25.
//

import SwiftUI
import SwiftData
import FirebaseAuth

struct SettingsView: View {
    @EnvironmentObject var sessionManager: SessionManager
    @Environment(\.modelContext) private var modelContext
    
    @State private var user: StoredUser?

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
                    
                    if let user = user {
                        FechaPicker(
                            label: "Fecha de tu próximo depósito",
                            selectedDate: Binding(
                                get: { user.fortnightDate },
                                set: { newDate in
                                    user.fortnightDate = newDate
                                    try? modelContext.save()
                                }),
                            title: true)
                        
                        DropdownField(
                            label: "Moneda principal", options: ["MXN", "AUD", "USD", "EUR" ],
                            selectedOption: Binding(
                            get: { user.currencyValue },
                            set: { new in
                                user.currencyValue = new
                                try? modelContext.save()
                            }),
                            title: true)
                        
                        MoneyField(
                            label: "Quincena",
                            amount: Binding(
                                get: { user.budgetValue },
                                set: { new in
                                    user.budgetValue = new ?? 0.00
                                    try? modelContext.save()
                                }
                            ),
                            currencyCode: user.currencyValue,
                            title: true,
                            placeholder: "0.00",
                            showsSymbol: true,
                            maximumFractionDigits: 2,
                            allowsNegative: false
                        )
                        .padding(.bottom, 24)
                    } else {
                        ProgressView("Cargando ajustes…")
                            .padding()
                    }
                    
                    VStack {
                        Spacer()
                        Button(
                            action: {
                                Task {
                                    await sessionManager.signOut()
                                }
                            }
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
        .onAppear {
            guard let uid = Auth.auth().currentUser?.uid else {
                print("⚠️ No hay usuario autenticado")
                return
            }
            let desc = FetchDescriptor<StoredUser>(
                predicate: #Predicate { $0.firebaseUID == uid })
            do {
                user = try modelContext.fetch(desc).first
            } catch {
                print("❌ Error al fetch de StoredUser:", error)
            }
        }
        .onTapGesture {
            UIApplication.shared.hideKeyboard()
        }
    }
}
