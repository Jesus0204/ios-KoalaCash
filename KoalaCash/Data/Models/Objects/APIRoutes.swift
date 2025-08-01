//
//  APIRoutes.swift
//  KoalaCash
//
//  Created by Jesus Cedillo on 01/08/25.
//

import Foundation

let exchangeRateAPIKey = Bundle.main.string(for: "EXCHANGERATE_API_KEY")

struct Api {
    // Esta es la base del URL (se usa en TODAS las llamadas)
    static let base = "https://api.exchangerate.host/live?access_key=\(exchangeRateAPIKey)"
}
