//
//  DropdownField.swift
//  KoalaCash
//
//  Created by Jesus Cedillo on 29/07/25.
//

import SwiftUI

struct DropdownField: View {
    var label: String
    var options: [String]
    @Binding var selectedOption: String
    @State private var isExpanded: Bool = false
    var title: Bool

    var body: some View {
        VStack(alignment: .leading) {
            if title {
                Text(label)
                    .font(.title3)
                    .bold()
            } else {
                Text(label)
                    .font(.caption)
            }
            Menu {
                ForEach(options, id: \.self) { option in
                    Button(action: {
                        selectedOption = option
                    }, label: {
                        Text(option)
                    })
                }
            } label: {
                HStack {
                    Text(selectedOption)
                        .foregroundColor(.black)
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.gray)
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.4)))
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 24)
    }
}
