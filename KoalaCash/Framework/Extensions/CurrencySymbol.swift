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
            "MXN": "$",
            "EUR": "€"
        ][self] ?? self
    }
}
