//
//  AddExpenseRequirement.swift
//  KoalaCash
//
//  Created by Jesus Cedillo on 01/08/25.
//

import Foundation
import SwiftData

protocol AddExpenseRequirementProtocol {
    func agregarGasto(name: String, currency: String, amount: Decimal, category: String, dividedBy: Int, excludedFromBudget: Bool, user: StoredUser, context: ModelContext) async -> Bool
}

class AddExpenseRequirement: AddExpenseRequirementProtocol {
    static let shared = AddExpenseRequirement()

    let expenseRepository: ExpenseRepository

    init(expenseRepository: ExpenseRepository = ExpenseRepository.shared) {
        self.expenseRepository = expenseRepository
    }

    func agregarGasto(name: String, currency: String, amount: Decimal, category: String, dividedBy: Int, excludedFromBudget: Bool, user: StoredUser, context: ModelContext) async -> Bool {
           return await expenseRepository.agregarGasto(name: name, currency: currency, amount: amount, category: category, dividedBy: dividedBy, excludedFromBudget: excludedFromBudget, user: user, context: context)
    }
}
