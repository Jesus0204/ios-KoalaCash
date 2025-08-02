//
//  Free.swift
//  KoalaCash
//
//  Created by Jesus Cedillo on 02/08/25.
//

import Foundation
import SwiftData

protocol FreezeExpenseRequirementProtocol {
    func congelarGasto(expenseID: String, context: ModelContext) async -> Bool
}

class FreezeExpenseRequirement: FreezeExpenseRequirementProtocol {
    static let shared = FreezeExpenseRequirement()

    let expenseRepository: ExpenseRepository

    init(expenseRepository: ExpenseRepository = ExpenseRepository.shared) {
        self.expenseRepository = expenseRepository
    }

    func congelarGasto(expenseID: String, context: ModelContext) async -> Bool {
        return await expenseRepository.congelarGasto(expenseID: expenseID, context: context)
    }
}
