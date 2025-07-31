//
//  OnboardingView.swift
//  KoalaCash
//
//  Created by Jesus Cedillo on 29/07/25.
//

import SwiftUI

struct OnboardingView: View {
    @State private var path: [SessionPaths] = []
    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                BackgroundView()

                VStack(spacing: 0) {
                    Spacer(minLength: 24)
                    
                    GeometryReader { proxy in
                        let heroH = min(proxy.size.height * 0.80, 560)
                        
                        VStack {
                            Spacer(minLength: 0)
                            Image("KoalaCashOnboarding")
                                .resizable()
                                .scaledToFit()
                                .frame(height: heroH)
                                .frame(maxWidth: .infinity)
                                .shadow(radius: 4, y: 2)
                            Spacer(minLength: 0)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    .frame(height: min(UIScreen.main.bounds.height * 0.55, 600))
                    .padding(.horizontal, 24)
                    
                    TitleSubtitleView(title: "Tu dinero, sin fronteras", subtitle: "Registra tus gastos, ve tu quincena y convierte entre dos monedas. Antes de pagar verás la tasa del día; al pagar, la congelamos. ¡No te pierdas el dinero que necesitas!")
                    
                    Spacer()

                    CustomButton(
                        text: "Empezar", action: {
                            path.append(.menu)
                        },
                        backgroundColor: .black,
                        foregroundColor: .white
                    )
                }
            }
            .navigationDestination(for: SessionPaths.self) { value in
                switch value {
                case .menu:
                    MenuView(path: $path)
                case .register:
                    InitialDataView(path: $path)
                case .forgottenPassword:
                    PasswordRecoveryView()
                }
            }
        }
    }
}

#Preview {
    OnboardingView()
}
