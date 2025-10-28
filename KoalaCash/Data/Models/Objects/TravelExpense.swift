//
//  TravelExpense.swift
//  KoalaCash
//
//  Created by Jesus Cedillo on 28/10/25.
//

import Foundation
import SwiftData

@Model
final class TravelExpense {
    @Attribute(.unique) var travelExpenseID: UUID
    var name: String
    var originalCurrency: String
    var convertedCurrency: String
    var originalAmount: Decimal
    var convertedAmount: Decimal
    var totalOriginalAmount: Decimal
    var totalConvertedAmount: Decimal
    var userCurrency: String = ""
    var userConvertedAmount: Decimal = 0
    var totalUserConvertedAmount: Decimal = 0
    var dividedBy: Int
    var datePurchase: Date
    var category: String
    var budgetExpenseID: UUID?

    @Relationship var trip: Trip?

    init(name: String,
         originalCurrency: String,
         convertedCurrency: String,
         originalAmount: Decimal,
         convertedAmount: Decimal,
         totalOriginalAmount: Decimal,
         totalConvertedAmount: Decimal,
         userCurrency: String,
         userConvertedAmount: Decimal,
         totalUserConvertedAmount: Decimal,
         dividedBy: Int,
         datePurchase: Date,
         category: String) {
        self.travelExpenseID = UUID()
        self.name = name
        self.originalCurrency = originalCurrency
        self.convertedCurrency = convertedCurrency
        self.originalAmount = originalAmount
        self.convertedAmount = convertedAmount
        self.totalOriginalAmount = totalOriginalAmount
        self.totalConvertedAmount = totalConvertedAmount
        self.userCurrency = userCurrency
        self.userConvertedAmount = userConvertedAmount
        self.totalUserConvertedAmount = totalUserConvertedAmount
        self.dividedBy = dividedBy
        self.datePurchase = datePurchase
        self.category = category
        self.budgetExpenseID = nil
    }
}
