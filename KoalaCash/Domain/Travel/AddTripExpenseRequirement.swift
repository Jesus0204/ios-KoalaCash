//
//  AddTripExpenseRequi}rement.swift
//  KoalaCash
//
//  Created by Jesus Cedillo on 28/10/25.
//

import Foundation
import SwiftData

protocol AddTripExpenseRequirementProtocol {
    func addExpense(to trip: Trip, name: String, currency: String, amount: Decimal, category: String, dividedBy: Int, context: ModelContext) async -> Bool
}

class AddTripExpenseRequirement: AddTripExpenseRequirementProtocol {
    static let shared = AddTripExpenseRequirement()

    let travelRepository: TravelRepository

    init(travelRepository: TravelRepository = TravelRepository.shared) {
        self.travelRepository = travelRepository
    }
    
    func addExpense(to trip: Trip, name: String, currency: String, amount: Decimal, category: String, dividedBy: Int, context: ModelContext) async -> Bool {
        await travelRepository.addExpense(to: trip, name: name, currency: currency, amount: amount, category: category, dividedBy: dividedBy, context: context)
    }
}
