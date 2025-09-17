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
    
    let exclusionStore = ExpenseExclusionStore.shared
    
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
    func agregarGasto(name: String, currency: String, amount: Decimal, category: String, dividedBy: Int, excludedFromBudget: Bool, user: StoredUser, context: ModelContext) async -> Bool {
        let userCurrency = user.currencyValue
        let url = Api.base + "&source=\(currency)&currencies=\(userCurrency)"
        
        let convertedTotal: Decimal
        var createdExpense: Expense?
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
            
            createdExpense = expense
            exclusionStore.setExcluded(excludedFromBudget, for: expense.expenseID)

            if let quincena = user.quincenas.first(where: { $0.active }) {
                quincena.expenses.append(expense)
                expense.quincena = quincena
                if !excludedFromBudget {
                    quincena.spent += perPersonConverted
                }
            }

            context.insert(expense)
            try context.save()
            return true
        } catch {
            print("Error agregando gasto: \(error)")
            if let expense = createdExpense {
                exclusionStore.remove(expense.expenseID)
            }
            return false
        }
    }
    
    @MainActor
    func eliminarGasto(expenseID: String, context: ModelContext) async -> Bool {
        guard let uuid = UUID(uuidString: expenseID) else { return false }

        let descriptor = FetchDescriptor<Expense>(predicate: #Predicate { $0.expenseID == uuid })
        do {
            if let expense = try context.fetch(descriptor).first {
                let isExcluded = exclusionStore.isExcluded(expense.expenseID)
                if let quincena = expense.quincena {
                    quincena.expenses.removeAll { $0.expenseID == expense.expenseID }
                    if !isExcluded {
                        quincena.spent -= expense.convertedAmount
                        if quincena.spent < 0 { quincena.spent = 0 }
                    }
                }
                context.delete(expense)
                exclusionStore.remove(expense.expenseID)
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

final class ExpenseExclusionStore {
    static let shared = ExpenseExclusionStore()

    private let defaults: UserDefaults
    private let storageKey = "ExcludedExpenseIDs"
    private var cachedIDs: Set<String>
    private let queue = DispatchQueue(label: "ExpenseExclusionStore.queue", qos: .userInitiated)

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        if let stored = defaults.array(forKey: storageKey) as? [String] {
            self.cachedIDs = Set(stored)
        } else {
            self.cachedIDs = []
        }
    }

    func isExcluded(_ id: UUID) -> Bool {
        queue.sync { cachedIDs.contains(id.uuidString) }
    }

    func setExcluded(_ excluded: Bool, for id: UUID) {
        queue.sync {
            if excluded {
                cachedIDs.insert(id.uuidString)
            } else {
                cachedIDs.remove(id.uuidString)
            }
            defaults.set(Array(cachedIDs), forKey: storageKey)
        }
    }

    func remove(_ id: UUID) {
        setExcluded(false, for: id)
    }
}
