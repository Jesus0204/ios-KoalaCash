//
//  AccountDataView.swift
//  KoalaCash
//
//  Created by Jesus Cedillo on 31/07/25.
//

import SwiftUI
import SwiftData

struct AccountDataView: View {
    @StateObject private var onboardingViewModel = OnboardingViewModel()
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var sessionManager: SessionManager
    
    var body: some View {
        ZStack {
            BackgroundView()
            
            ScrollView {
                VStack {
                    TitleSubtitleView(title: "Crea tu cuenta", subtitle: "Ingresa un apodo, correo electrónico y contraseña.")

                    HStack {
                        Spacer()
                        Image("Koala_FinishAccount")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 180)
                            .accessibilityHidden(true)
                        Spacer()
                    }

                    VStack(alignment: .leading) {
                        Text("Apodo")
                            .font(.title3)
                            .bold()

                        TextField("Ingresa tu apodo", text: $onboardingViewModel.nickname)
                            .textInputAutocapitalization(.never)
                            .padding()
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                            )
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 8)

                    EmailField(
                        email: $onboardingViewModel.email,
                        text: "Correo electrónico",
                        placeholder: "Escribe tu correo..."
                    )
                    .padding(.bottom, 10)

                    PasswordField(
                        password: $onboardingViewModel.password,
                        isPasswordVisible: $onboardingViewModel.isPasswordVisible,
                        text: "Contraseña"
                    )
                    .padding(.horizontal, 24)
                    .padding(.bottom, 10)

                    PasswordField(
                        password: $onboardingViewModel.confirmPassword,
                        isPasswordVisible: $onboardingViewModel.isConfirmVisible,
                        placeholder: "Confirma tu contraseña",
                        text: "Confirmar contraseña"
                    )
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
                    
                    CustomButton(
                        text: "Crear cuenta",
                        action: {
                            Task {
                                await onboardingViewModel.registrarUsuario(context: modelContext)
                                sessionManager.reloadStoredUser()
                            }
                        },
                        backgroundColor: .black,
                        foregroundColor: .white
                    )
                }
            }
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

#Preview {
    AccountDataView()
}
