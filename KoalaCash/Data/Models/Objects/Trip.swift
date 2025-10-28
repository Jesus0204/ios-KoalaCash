//
//  Trip.swift
//  KoalaCash
//
//  Created by Jesus Cedillo on 28/10/25.
//

import Foundation
import SwiftData

@Model
final class Trip {
    @Attribute(.unique) var tripID: UUID
    var name: String
    var startDate: Date
    var endDate: Date?
    var baseCurrency: String
    var totalConvertedAmount: Decimal
    var totalUserConvertedAmount: Decimal

    @Relationship var user: StoredUser?

    @Relationship(inverse: \TravelExpense.trip) var expenses: [TravelExpense] = []

    init(name: String, startDate: Date, endDate: Date?, baseCurrency: String) {
        self.tripID = UUID()
        self.name = name
        self.startDate = startDate
        self.endDate = endDate
        self.baseCurrency = baseCurrency
        self.totalConvertedAmount = 0
        self.totalUserConvertedAmount = 0
    }
}

extension Trip {
    var dateRangeText: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        if let endDate {
            return "\(formatter.string(from: startDate)) - \(formatter.string(from: endDate))"
        } else {
            return formatter.string(from: startDate)
        }
    }

    var isActive: Bool {
        let now = Date()
        if let endDate {
            return now >= startDate && now <= endDate
        }
        return now >= startDate
    }
}
