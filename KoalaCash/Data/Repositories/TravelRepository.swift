//
//  TravelRepository.swift
//  KoalaCash
//
//  Created by Jesus Cedillo on 28/10/25.
//

import Foundation
import SwiftData

protocol TravelAPIProtocol {
    func addTrip(name: String, startDate: Date, endDate: Date?, currency: String, user: StoredUser, context: ModelContext) async -> Bool
    func deleteTrip(tripID: String, context: ModelContext) async -> Bool
    func addExpense(to trip: Trip, name: String, currency: String, amount: Decimal, category: String, dividedBy: Int, context: ModelContext) async -> Bool
    func deleteExpense(expenseID: String, context: ModelContext) async -> Bool
}

class TravelRepository: TravelAPIProtocol {
    static let shared = TravelRepository()

    let travelService: TravelAPIService

    init(travelService: TravelAPIService = .shared) {
        self.travelService = travelService
    }
    
    func addTrip(name: String, startDate: Date, endDate: Date?, currency: String, user: StoredUser, context: ModelContext) async -> Bool {
        await travelService.addTrip(name: name, startDate: startDate, endDate: endDate, currency: currency, user: user, context: context)
    }

    func deleteTrip(tripID: String, context: ModelContext) async -> Bool {
        await travelService.deleteTrip(tripID: tripID, context: context)
    }

    func addExpense(to trip: Trip, name: String, currency: String, amount: Decimal, category: String, dividedBy: Int, context: ModelContext) async -> Bool {
        await travelService.addExpense(to: trip, name: name, currency: currency, amount: amount, category: category, dividedBy: dividedBy, context: context)
    }

    func deleteExpense(expenseID: String, context: ModelContext) async -> Bool {
        await travelService.deleteExpense(expenseID: expenseID, context: context)
    }
}
