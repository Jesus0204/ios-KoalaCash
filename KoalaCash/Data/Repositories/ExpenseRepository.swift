//
//  ExpenseRepository.swift
//  KoalaCash
//
//  Created by Jesus Cedillo on 01/08/25.
//

import Foundation
import SwiftData

protocol ExpenseAPIProtocol {
    func agregarGasto(name: String, currency: String, amount: Decimal, category: String, dividedBy: Int, excludedFromBudget: Bool, user: StoredUser, context: ModelContext) async -> UUID?
    func eliminarGasto(expenseID: String, context: ModelContext) async -> Bool
}

class ExpenseRepository: ExpenseAPIProtocol {
    static let shared = ExpenseRepository()

    let expenseService: ExpenseAPIService

    init(expenseService: ExpenseAPIService = ExpenseAPIService.shared) {
        self.expenseService = expenseService
    }

    func agregarGasto(name: String, currency: String, amount: Decimal, category: String, dividedBy: Int, excludedFromBudget: Bool, user: StoredUser, context: ModelContext) async -> UUID? {
        return await expenseService.agregarGasto(name: name, currency: currency, amount: amount, category: category, dividedBy: dividedBy, excludedFromBudget: excludedFromBudget, user: user, context: context)
    }
    
    func eliminarGasto(expenseID: String, context: ModelContext) async -> Bool {
        return await expenseService.eliminarGasto(expenseID: expenseID, context: context)
    }
}
