//
//  MoneyField.swift
//  KoalaCash
//
//  Created by Jesus Cedillo on 30/07/25.
//

import SwiftUI

struct MoneyField: View {
    var label: String
    @Binding var amount: Decimal?
    var currencyCode: String = "AUD"
    var title: Bool = false
    var placeholder: String = "0.00"
    var showsSymbol: Bool = true
    var maximumFractionDigits: Int = 2
    var allowsNegative: Bool = false

    @FocusState private var isFocused: Bool

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

            HStack(spacing: 8) {
                if showsSymbol {
                    Text(currencySymbol)
                        .foregroundColor(.gray)
                }

                TextField(localizedPlaceholder, value: $amount, format: numberFormat)
                    .keyboardType(.decimalPad)
                    .focused($isFocused)
                    .onChange(of: amount ?? 0.00) { oldValue, newValue in
                        if !allowsNegative && newValue < 0 {
                            amount = 0
                        }
                    }
                    .toolbar {
                        ToolbarItemGroup(placement: .keyboard) {
                            Spacer()
                            Button("Done") {
                                isFocused = false
                            }
                        }
                    }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray.opacity(0.4))
            )
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 8)
    }

    // MARK: - Helpers

    private var numberFormat: Decimal.FormatStyle {
        Decimal.FormatStyle(locale: Locale.current)
            .precision(.fractionLength(0...maximumFractionDigits))
            .grouping(.automatic)
    }
    
    private var currencySymbol: String {
        [
            "USD": "$",
            "AUD": "A$",
            "MXN": "$",
            "EUR": "€"
        ][currencyCode] ?? currencyCode
    }
    
    private var localizedPlaceholder: String {
        let nf = NumberFormatter()
        nf.numberStyle = .decimal
        nf.minimumFractionDigits = maximumFractionDigits
        nf.maximumFractionDigits = maximumFractionDigits
        nf.locale = Locale.current
        return nf.string(from: 0) ?? placeholder
    }
}
