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
    
    func convert(amount: Decimal, from currency: String, to target: String) async throws -> Decimal {
        if currency == target {
            return amount
        }

        let url = Api.base + "&source=\(currency)&currencies=\(target)"
        let data = try await session.request(url).serializingData().value
        let response = try JSONDecoder().decode(ExchangeRateResponse.self, from: data)
        let rateKey = "\(currency)\(target)"
        let rate = response.quotes?[rateKey] ?? response.rates?[target] ?? 1.0
        return amount * Decimal(rate)
    }
    
    @MainActor
    func agregarGasto(name: String, currency: String, amount: Decimal, category: String, dividedBy: Int, user: StoredUser, context: ModelContext) async -> Bool {
        let userCurrency = user.currencyValue
        let url = Api.base + "&source=\(currency)&currencies=\(userCurrency)"
        
        let convertedTotal: Decimal
        do {
            if currency != userCurrency {
                let data = try await session.request(url).serializingData().value
                let response = try JSONDecoder().decode(ExchangeRateResponse.self, from: data)

                let rateKey = "\(currency)\(userCurrency)"
                let rate = response.quotes?[rateKey] ?? response.rates?[userCurrency] ?? 1.0
                convertedTotal = amount * Decimal(rate)
            } else {
                convertedTotal = amount
            }
            
            let perPersonOriginal = amount / Decimal(dividedBy)
            let perPersonConverted = convertedTotal / Decimal(dividedBy)

            let expense = Expense(name: name,
                                  originalCurrency: currency,
                                  convertedCurrency: userCurrency,
                                  originalAmount: perPersonOriginal,
                                  convertedAmount: perPersonConverted,
                                  totalOriginalAmount: amount,
                                  totalConvertedAmount: convertedTotal,
                                  datePurchase: Date(),
                                  category: category,
                                  dividedBy: dividedBy)

            if let quincena = user.quincenas.first(where: { $0.active }) {
                quincena.expenses.append(expense)
                expense.quincena = quincena
                quincena.spent += perPersonConverted
            }

            context.insert(expense)
            try context.save()
            return true
        } catch {
            print("Error agregando gasto: \(error)")
            return false
        }
    }
    
    @MainActor
    func eliminarGasto(expenseID: String, context: ModelContext) async -> Bool {
        guard let uuid = UUID(uuidString: expenseID) else { return false }

        let descriptor = FetchDescriptor<Expense>(predicate: #Predicate { $0.expenseID == uuid })
        do {
            if let expense = try context.fetch(descriptor).first {
                if let quincena = expense.quincena {
                    quincena.expenses.removeAll { $0.expenseID == expense.expenseID }
                    quincena.spent -= expense.convertedAmount
                    if quincena.spent < 0 { quincena.spent = 0 }
                }
                context.delete(expense)
                try context.save()
                return true
            }
            return false
        } catch {
            print("Error eliminando gasto: \(error)")
            return false
        }
    }
}
