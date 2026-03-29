//
//  ExpenseAPIService.swift
//  KoalaCash
//
//  Created by Jesus Cedillo on 01/08/25.
//

import Foundation
import SwiftData
import Alamofire

struct ExchangeRateErrorResponse: Decodable {
    let code: Int
    let type: String
    let info: String
}

struct ExchangeRateResponse: Decodable {
    let success: Bool?
    let quotes: [String: Double]?
    let rates: [String: Double]?
    let error: ExchangeRateErrorResponse?

    func rate(from source: String, to target: String) -> Double? {
        let normalizedSource = source.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        let normalizedTarget = target.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        let rateKey = "\(normalizedSource)\(normalizedTarget)"

        if let rate = quotes?[rateKey] { return rate }
        if let rate = rates?[normalizedTarget] { return rate }
        return nil
    }
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
    
    func convert(amount: Decimal, from currency: String, to targets: [String]) async throws -> [String: Decimal] {
        let normalizedSource = currency.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        let normalizedTargets = Array(
            Set(
                targets.map { $0.trimmingCharacters(in: .whitespacesAndNewlines).uppercased() }
            )
        )

        if normalizedTargets.isEmpty { return [:] }

        var convertedValues: [String: Decimal] = [:]
        let targetsToRequest = normalizedTargets.filter { $0 != normalizedSource }

        if targetsToRequest.isEmpty {
            normalizedTargets.forEach { convertedValues[$0] = amount }
            return convertedValues
        }

        let currencies = targetsToRequest.joined(separator: ",")
        let url = Api.base + "&source=\(normalizedSource)&currencies=\(currencies)"
        let data = try await session.request(url).serializingData().value
        let response = try JSONDecoder().decode(ExchangeRateResponse.self, from: data)
        try await APIUsageLimitNotifier.shared.handleUsageLimitIfNeeded(response: response)

        for target in normalizedTargets {
            if target == normalizedSource {
                convertedValues[target] = amount
                continue
            }

            guard let rate = response.rate(from: normalizedSource, to: target) else {
                throw APIServiceError.missingRate
            }
            convertedValues[target] = amount * Decimal(rate)
        }

        return convertedValues
    }
    
    func convert(amount: Decimal, from currency: String, to target: String) async throws -> Decimal {
            let normalizedTarget = target.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
            let convertedValues = try await convert(amount: amount, from: currency, to: [normalizedTarget])

            guard let converted = convertedValues[normalizedTarget] else {
                throw APIServiceError.missingRate
            }
        
        return converted
    }

    
    @MainActor
    func agregarGasto(name: String,
                          currency: String,
                          amount: Decimal,
                          category: String,
                          dividedBy: Int,
                          excludedFromBudget: Bool,
                          user: StoredUser,
                          context: ModelContext,
                          preConvertedTotalInUserCurrency: Decimal? = nil) async -> UUID? {
        let normalizedCurrency = currency.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        let userCurrency = user.currencyValue.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        let url = Api.base + "&source=\(normalizedCurrency)&currencies=\(userCurrency)"
        
        let convertedTotal: Decimal
        var createdExpense: Expense?
        do {
            if let preConvertedTotalInUserCurrency {
                convertedTotal = preConvertedTotalInUserCurrency
            } else if normalizedCurrency != userCurrency {
                let data = try await session.request(url).serializingData().value
                let response = try JSONDecoder().decode(ExchangeRateResponse.self, from: data)
                try await APIUsageLimitNotifier.shared.handleUsageLimitIfNeeded(response: response)

                guard let rate = response.rate(from: normalizedCurrency, to: userCurrency) else {
                    throw APIServiceError.missingRate
                }
                
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
            return expense.expenseID
        } catch {
            print("Error agregando gasto: \(error)")
            if let expense = createdExpense {
                exclusionStore.remove(expense.expenseID)
            }
            return nil
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
