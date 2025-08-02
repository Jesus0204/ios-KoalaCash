//
//  ExpenseAPIService.swift
//  KoalaCash
//
//  Created by Jesus Cedillo on 01/08/25.
//

import Foundation
import SwiftData
import Alamofire

struct ExchangeRateResponse: Decodable {
    let quotes: [String: Double]?
    let rates: [String: Double]?
}

class ExpenseAPIService {
    static let shared = ExpenseAPIService()
    
    let session = Session(configuration: {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 7.5
        configuration.timeoutIntervalForResource = 15
        return configuration
    }())
    
    @MainActor
    func agregarGasto(name: String, currency: String, amount: Decimal, category: String, user: StoredUser, context: ModelContext) async -> Bool {
        let userCurrency = user.currencyValue
        let url = Api.base + "&source=\(currency)&currencies=\(userCurrency)"
        
        let converted : Decimal
        do {
            if currency != userCurrency {
                let data = try await session.request(url).serializingData().value
                let response = try JSONDecoder().decode(ExchangeRateResponse.self, from: data)

                let rateKey = "\(currency)\(userCurrency)"
                let rate = response.quotes?[rateKey] ?? response.rates?[userCurrency] ?? 1.0
                converted = amount * Decimal(rate)
            } else {
                converted = amount
            }

            let expense = Expense(name: name, originalCurrency: currency, convertedCurrency: userCurrency, originalAmount: amount, convertedAmount: converted, datePurchase: Date(), category: category)

            if let quincena = user.quincenas.first(where: { $0.active }) {
                quincena.expenses.append(expense)
                expense.quincena = quincena
                quincena.spent += converted
            }

            context.insert(expense)
            try context.save()
            return true
        } catch {
            print("Error agregando gasto: \(error)")
            return false
        }
    }
}
