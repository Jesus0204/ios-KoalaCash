//
//  TravelAPIService.swift
//  KoalaCash
//
//  Created by Jesus Cedillo on 28/10/25.
//

import Foundation
import SwiftData
import Alamofire

class TravelAPIService {
    static let shared = TravelAPIService()

    private let session = Session(configuration: {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 7.5
        configuration.timeoutIntervalForResource = 15
        return configuration
    }())

    func convert(amount: Decimal, from currency: String, to target: String) async throws -> Decimal {
        if currency == target { return amount }

        let url = Api.base + "&source=\(currency)&currencies=\(target)"
        let data = try await session.request(url).serializingData().value
        let response = try JSONDecoder().decode(ExchangeRateResponse.self, from: data)
        let rateKey = "\(currency)\(target)"
        let rate = response.quotes?[rateKey] ?? response.rates?[target] ?? 1.0
        return amount * Decimal(rate)
    }

    @MainActor
    func addTrip(name: String,
                 startDate: Date,
                 endDate: Date?,
                 currency: String,
                 user: StoredUser,
                 context: ModelContext) async -> Bool {
        let trip = Trip(name: name, startDate: startDate, endDate: endDate, baseCurrency: currency)
        trip.user = user
        user.trips.append(trip)

        context.insert(trip)

        do {
            try context.save()
            return true
        } catch {
            print("Error al guardar viaje: \(error)")
            return false
        }
    }

    @MainActor
    func deleteTrip(tripID: String, context: ModelContext) async -> Bool {
        guard let uuid = UUID(uuidString: tripID) else { return false }
        
        let descriptor = FetchDescriptor<Trip>(predicate: #Predicate { $0.tripID == uuid })
        do {
            if let trip = try context.fetch(descriptor).first {
                context.delete(trip)
                try context.save()
                return true
            }
        } catch {
            print("Error eliminando viaje: \(error)")
        }
        return false
    }

    @MainActor
    func addExpense(to trip: Trip,
                    name: String,
                    currency: String,
                    amount: Decimal,
                    category: String,
                    dividedBy: Int,
                    context: ModelContext) async -> Bool {
        let convertedTotal: Decimal
        do {
            if currency == trip.baseCurrency {
                convertedTotal = amount
            } else {
                convertedTotal = try await convert(amount: amount, from: currency, to: trip.baseCurrency)
            }

            let perPersonOriginal = amount / Decimal(dividedBy)
            let perPersonConverted = convertedTotal / Decimal(dividedBy)

            let expense = TravelExpense(name: name,
                                        originalCurrency: currency,
                                        convertedCurrency: trip.baseCurrency,
                                        originalAmount: perPersonOriginal,
                                        convertedAmount: perPersonConverted,
                                        totalOriginalAmount: amount,
                                        totalConvertedAmount: convertedTotal,
                                        dividedBy: dividedBy,
                                        datePurchase: Date(),
                                        category: category)

            expense.trip = trip
            trip.expenses.append(expense)
            trip.totalConvertedAmount += convertedTotal

            context.insert(expense)
            try context.save()
            return true
        } catch {
            print("Error agregando gasto de viaje: \(error)")
            return false
        }
    }

    @MainActor
    func deleteExpense(expenseID: String, context: ModelContext) async -> Bool {
        guard let uuid = UUID(uuidString: expenseID) else { return false }
        
        let descriptor = FetchDescriptor<TravelExpense>(predicate: #Predicate { $0.travelExpenseID == uuid })
        do {
            if let expense = try context.fetch(descriptor).first {
                if let trip = expense.trip {
                    trip.expenses.removeAll { $0.travelExpenseID == expense.travelExpenseID }
                    trip.totalConvertedAmount -= expense.totalConvertedAmount
                    if trip.totalConvertedAmount < 0 { trip.totalConvertedAmount = 0 }
                }
                context.delete(expense)
                try context.save()
                return true
            }
        } catch {
            print("Error eliminando gasto de viaje: \(error)")
        }
        return false
    }
}
