//
//  PasswordRecoveryView.swift
//  KoalaCash
//
//  Created by Jesus Cedillo on 31/07/25.
//

import SwiftUI

struct PasswordRecoveryView: View {
    @Binding var path: [SessionPaths]
    
    @StateObject private var resetPasswordViewModel = RestablecerContraseñaViewModel()

    var body: some View {
        ZStack {
            BackgroundView()
            
            ScrollView {
                VStack {
                    HStack {
                        Spacer()
                        Image("KoalaCashLogo")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 150)
                            .accessibilityHidden(true)
                        Spacer()
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 20)
                    
                    TitleSubtitleView(
                        title: "Recupera tu contraseña",
                        subtitle: "Entendemos que estas cosas pasan. No te preocupes, solo necesitamos un correo electrónico para enviarte un link para recuperar tu contraseña.")
                    .padding(.bottom, 20)
                    
                    EmailField(email: $resetPasswordViewModel.email,
                               text: "Correo electrónico o usuario",
                               placeholder: "Escribe tu correo...")
                    .padding(.bottom, 20)
                    
                    CustomButton(
                        text: "Enviar enlace",
                        action: {
                            Task {
                                await resetPasswordViewModel.emailRestablecerContraseña()
                            }
                        },
                        backgroundColor: .black,
                        foregroundColor: .white
                    )
                }
            }
            .onTapGesture {
                UIApplication.shared.hideKeyboard()
            }
            .alert(isPresented: $resetPasswordViewModel.showAlert) {
                if resetPasswordViewModel.alertSuccess == true {
                    return Alert(
                        title: Text("¡Éxito!"),
                        message: Text(resetPasswordViewModel.messageAlert),
                        dismissButton: .default(Text("OK")) {
                            path.removeLast()
                        }
                    )
                } else {
                    return Alert(
                        title: Text("Oops!"),
                        message: Text(resetPasswordViewModel.messageAlert),
                        dismissButton: .default(Text("OK"))
                    )
                }
            }
        }
    }
}

struct PasswordRecoveryView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapper()
    }

    struct PreviewWrapper: View {
        @State var path: [SessionPaths] = []

        var body: some View {
            PasswordRecoveryView(path: $path)
        }
    }
}
