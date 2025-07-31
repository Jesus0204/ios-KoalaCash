//
//  CustomButton.swift
//  KoalaCash
//
//  Created by Jesus Cedillo on 29/07/25.
//

import SwiftUI

struct CustomButton: View {
    var text: String
    var action: () -> Void
    var tieneIcono: Bool?
    var icono: String?
    var backgroundColor: Color
    var foregroundColor: Color = .black
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(text)
                    .font(.system(.headline, design: .rounded))
                    .bold()

                if tieneIcono ?? false {
                    Image(systemName: icono ?? "chevron.right")
                }
            }
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity)
            .foregroundColor(foregroundColor)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 24)
        .buttonStyle(PlainButtonStyle())
    }
}
