//
//  CurrencySymbol.swift
//  KoalaCash
//
//  Created by Jesus Cedillo on 02/08/25.
//

import Foundation

extension String {
    var currencySymbol: String {
        [
            "USD": "$",
            "AUD": "A$",
            "NZD": "NZ$",
            "MXN": "$",
            "EUR": "€",
            "JPY": "¥",
            "KRW": "₩"
        ][self] ?? self
    }
}
