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
    var name: String
    var originalCurrency: String
    var convertedCurrency: String
    var originalAmount: Decimal
    var convertedAmount: Decimal
    var totalOriginalAmount: Decimal
    var totalConvertedAmount: Decimal
    var dividedBy: Int
    var datePurchase: Date
    var category: String
    
    @Relationship var quincena: Quincena?

    init(name: String, originalCurrency: String, convertedCurrency: String, originalAmount: Decimal, convertedAmount: Decimal, totalOriginalAmount: Decimal, totalConvertedAmount: Decimal, datePurchase: Date, category: String, dividedBy: Int = 1) {
        self.expenseID = UUID()
        self.name = name
        self.originalCurrency = originalCurrency
        self.convertedCurrency = convertedCurrency
        self.originalAmount = originalAmount
        self.convertedAmount = convertedAmount
        self.totalOriginalAmount = totalOriginalAmount
        self.totalConvertedAmount = totalConvertedAmount
        self.dividedBy = dividedBy
        self.datePurchase = datePurchase
        self.category = category
    }
}
