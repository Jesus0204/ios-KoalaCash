//
//  EmailField.swift
//  KoalaCash
//
//  Created by Jesus Cedillo on 31/07/25.
//

import SwiftUI
import Combine

struct EmailField: View {
    @Binding var email: String
    var text: String
    var placeholder: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(text)
                .font(.title3)
                .bold()
            
            TextField(placeholder, text: $email)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .padding()
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                )
                .onReceive(Just(email)) { _ in
                    if email.count > 100 {
                        email = String(email.prefix(100))
                    }
                }
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 8)
    }
}
