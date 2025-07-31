//
//  MoneyField.swift
//  KoalaCash
//
//  Created by Jesus Cedillo on 30/07/25.
//

import SwiftUI

struct MoneyField: View {
    var label: String
    @Binding var amount: Decimal
    var currencyCode: String = "AUD"
    var title: Bool = false
    var placeholder: String = "0.00"
    var showsSymbol: Bool = true
    var maximumFractionDigits: Int = 2
    var allowsNegative: Bool = false

    @State private var text: String = ""
    @FocusState private var isFocused: Bool

    private var formatter: NumberFormatter {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.currencyCode = currencyCode
        f.maximumFractionDigits = maximumFractionDigits
        f.minimumFractionDigits = 0
        f.usesGroupingSeparator = true
        return f
    }

    private var plainNumberFormatter: NumberFormatter {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.maximumFractionDigits = maximumFractionDigits
        f.minimumFractionDigits = 0
        f.usesGroupingSeparator = false
        return f
    }

    private var currencySymbol: String {
        formatter.currencySymbol ?? "$"
    }

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

                TextField(placeholder, text: $text)
                    .keyboardType(.decimalPad)
                    .focused($isFocused)
                    .onChange(of: isFocused) { oldValue, newValue in
                        if newValue {
                            text = plainString(from: amount)
                        } else {
                            text = formattedString(from: amount) 
                        }
                    }

                    .onChange(of: text) { oldValue, newValue in
                        let sanitized = sanitize(newValue)
                        if sanitized != newValue { text = sanitized }

                        if let parsed = parseDecimal(from: sanitized) {
                            amount = rounded(parsed)
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
        .onAppear {
            text = formattedString(from: amount)
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 24)
    }

    // MARK: - Helpers

    private func sanitize(_ input: String) -> String {
        let decSep = formatter.decimalSeparator ?? "."
        var result = ""
        var hasDecimal = false

        for (idx, ch) in input.enumerated() {
            if ch.isNumber {
                result.append(ch)
                continue
            }

            if String(ch) == decSep {
                if !hasDecimal {
                    hasDecimal = true
                    result.append(ch)
                }
                continue
            }

            if allowsNegative && ch == "-" {
                if idx == 0 && !result.contains("-") {
                    result.insert("-", at: result.startIndex)
                }
                continue
            }
        }

        if hasDecimal, let range = result.range(of: decSep) {
            let fractional = result[range.upperBound...]
            if fractional.count > maximumFractionDigits {
                let endIdx = result.index(range.upperBound, offsetBy: maximumFractionDigits)
                result = String(result[..<endIdx].prefix(result.distance(from: result.startIndex, to: range.upperBound))) +
                         String(result[range.upperBound..<endIdx])
            }
        }

        return result
    }

    private func parseDecimal(from input: String) -> Decimal? {
        let decSep = formatter.decimalSeparator ?? "."
        let normalized = input.replacingOccurrences(of: decSep, with: ".")
        return Decimal(string: normalized)
    }

    private func formattedString(from value: Decimal) -> String {
        let number = NSDecimalNumber(decimal: value)
        return formatter.string(from: number) ?? "\(value)"
    }

    private func plainString(from value: Decimal) -> String {
        let number = NSDecimalNumber(decimal: value)
        return plainNumberFormatter.string(from: number) ?? ""
    }

    private func rounded(_ value: Decimal) -> Decimal {
        var val = value
        var result = Decimal()
        NSDecimalRound(&result, &val, maximumFractionDigits, .bankers)
        return result
    }
}
