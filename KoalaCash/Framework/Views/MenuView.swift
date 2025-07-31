//
//  MenuView.swift
//  KoalaCash
//
//  Created by Jesus Cedillo on 31/07/25.
//

import SwiftUI

struct MenuView: View {
    @Binding var path: [SessionPaths]
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isPasswordVisible: Bool = false
    
    var body: some View {
        ZStack {
            BackgroundView()
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
                .padding(.bottom, 10)

                TitleSubtitleView(
                    title: "Bienvenido a KoalaCash",
                    subtitle: "Administra tu dinero de forma sencilla y en dos monedas."
                            )
                .padding(.bottom, 32)
                
                VStack(spacing: 16) {
                    VStack(alignment: .leading) {
                        EmailField(email: $email,
                                   text: "Correo electrónico",
                                   placeholder: "Escribe tu correo...")
                    }
                    
                    VStack(alignment: .leading) {
                        PasswordField(
                            password: $password,
                            isPasswordVisible: $isPasswordVisible,
                            text: "Contraseña"
                        )
                    }
                    .padding(.horizontal, 24)
                    
                    Button(
                        action: {
                            path.append(.forgottenPassword)
                        }
                    ){
                        Text("¿Olvidaste tu contraseña?")
                            .underline()
                            .font(.system(.body, design: .rounded))
                            .foregroundColor(.black)
                    }
                    .padding(.bottom, 16)
                    .buttonStyle(PlainButtonStyle())
                }

                Spacer()

                CustomButton(
                    text: "Iniciar sesión",
                    action: {},
                    backgroundColor: .black,
                    foregroundColor: .white
                )
                .padding(.top, 10)
                
                SecondaryButton(text: "Crear cuenta") {
                    path.append(.register)
                }
            }
            .onTapGesture {
                UIApplication.shared.hideKeyboard()
            }
        }
    }
}

struct MenuView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapper()
    }

    struct PreviewWrapper: View {
        @State var path: [SessionPaths] = []

        var body: some View {
            MenuView(path: $path)
        }
    }
}
