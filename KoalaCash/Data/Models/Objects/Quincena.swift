//
//  Quincena.swift
//  KoalaCash
//
//  Created by Jesus Cedillo on 01/08/25.
//

import Foundation
import SwiftData

@Model
final class Quincena {
    @Attribute(.unique) var quincenaID: UUID
    var fechaInicio: Date
    var fechaFin: Date
    var budgetAmount: Decimal
    var budgetCurrency: String
    var spent: Decimal
    var active: Bool
    
    @Relationship var user: StoredUser?
    
    @Relationship(inverse: \Expense.quincena) var expenses: [Expense] = []
    
    init(fechaInicio: Date, fechaFin: Date, budgetAmount: Decimal, budgetCurrency: String, spent: Decimal, active: Bool) {
        self.quincenaID = UUID()
        self.fechaInicio = fechaInicio
        self.fechaFin = fechaFin
        self.budgetAmount = budgetAmount
        self.budgetCurrency = budgetCurrency
        self.spent = spent
        self.active = active
    }
}
