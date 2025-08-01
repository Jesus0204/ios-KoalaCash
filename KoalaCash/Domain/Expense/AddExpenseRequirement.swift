//
//  AddExpenseRequirement.swift
//  KoalaCash
//
//  Created by Jesus Cedillo on 01/08/25.
//

import Foundation
import SwiftData

protocol AddExpenseRequirementProtocol {
    func agregarGasto(currency: String, amount: Decimal, category: String, user: StoredUser, context: ModelContext) async -> Bool
}

class AddExpenseRequirement: AddExpenseRequirementProtocol {
    static let shared = AddExpenseRequirement()

    let expenseRepository: ExpenseRepository

    init(expenseRepository: ExpenseRepository = ExpenseRepository.shared) {
        self.expenseRepository = expenseRepository
    }

    func agregarGasto(currency: String, amount: Decimal, category: String, user: StoredUser, context: ModelContext) async -> Bool {
        return await expenseRepository.agregarGasto(currency: currency, amount: amount, category: category, user: user, context: context)
    }
}
