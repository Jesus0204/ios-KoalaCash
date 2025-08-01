//
//  Expense.swift
//  KoalaCash
//
//  Created by Jesus Cedillo on 01/08/25.
//

import Foundation
import SwiftData

@Model
final class Expense {
    @Attribute(.unique) var expenseID: UUID
    var originalCurrency: String
    var convertedCurrency: String
    var originalAmount: Decimal
    var convertedAmount: Decimal
    var datePurchase: Date
    var category: String
    var frozen: Bool = false
    
    @Relationship var quincena: Quincena?

    init(originalCurrency: String, convertedCurrency: String, originalAmount: Decimal, convertedAmount: Decimal, datePurchase: Date, category: String, frozen: Bool = false) {
        self.expenseID = UUID()
        self.originalCurrency = originalCurrency
        self.convertedCurrency = convertedCurrency
        self.originalAmount = originalAmount
        self.convertedAmount = convertedAmount
        self.datePurchase = datePurchase
        self.category = category
        self.frozen = frozen
    }
}
