//
//  DeleteTripExpenseRequirement.swift
//  KoalaCash
//
//  Created by Jesus Cedillo on 28/10/25.
//

import Foundation
import SwiftData

protocol DeleteTripExpenseRequirementProtocol {
    func deleteExpense(expenseID: String, context: ModelContext) async -> Bool
}

class DeleteTripExpenseRequirement: DeleteTripExpenseRequirementProtocol {
    static let shared = DeleteTripExpenseRequirement()

    let travelRepository: TravelRepository

    init(travelRepository: TravelRepository = TravelRepository.shared) {
        self.travelRepository = travelRepository
    }
    
    func deleteExpense(expenseID: String, context: ModelContext) async -> Bool {
        await travelRepository.deleteExpense(expenseID: expenseID, context: context)
    }
}
