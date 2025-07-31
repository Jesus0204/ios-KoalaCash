//
//  PasswordRecoveryView.swift
//  KoalaCash
//
//  Created by Jesus Cedillo on 31/07/25.
//

import SwiftUI

struct PasswordRecoveryView: View {
    @State private var email: String = ""

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
                    
                    EmailField(email: $email,
                               text: "Correo electrónico o usuario",
                               placeholder: "Escribe tu correo...")
                    .padding(.bottom, 20)
                    
                    CustomButton(
                        text: "Enviar enlace",
                        action: {},
                        backgroundColor: .black,
                        foregroundColor: .white
                    )
                }
            }
        }
    }
}

#Preview {
    PasswordRecoveryView()
}
