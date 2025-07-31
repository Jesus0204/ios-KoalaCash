//
//  OnboardingView.swift
//  KoalaCash
//
//  Created by Jesus Cedillo on 29/07/25.
//

import SwiftUI

struct OnboardingView: View {
    var body: some View {
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
                
                TitleSubtitleView(title: "Tu dinero, sin fronteras", subtitle: "Recibe cada mes y administra en dos monedas. Controla gastos, conversión y lo que te queda.")
                
                Spacer()

                CustomButton(
                    text: "Empezar", action: {},
                    backgroundColor: .black,
                    foregroundColor: .white
                )
            }
        }
    }
}

#Preview {
    OnboardingView()
}
