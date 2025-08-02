//
//  DeleteExpenseRequirement.swift
//  KoalaCash
//
//  Created by OpenAI Codex on 2023.
//

import Foundation
import SwiftData

protocol DeleteExpenseRequirementProtocol {
    func eliminarGasto(expenseID: String, context: ModelContext) async -> Bool
}

class DeleteExpenseRequirement: DeleteExpenseRequirementProtocol {
    static let shared = DeleteExpenseRequirement()

    let expenseRepository: ExpenseRepository

    init(expenseRepository: ExpenseRepository = ExpenseRepository.shared) {
        self.expenseRepository = expenseRepository
    }

    func eliminarGasto(expenseID: String, context: ModelContext) async -> Bool {
        return await expenseRepository.eliminarGasto(expenseID: expenseID, context: context)
    }
}
