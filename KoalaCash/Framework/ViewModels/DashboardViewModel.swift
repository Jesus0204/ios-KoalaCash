//
//  DashboardViewModel.swift
//  KoalaCash
//
//  Created by Jesus Cedillo on 01/08/25.
//

import Foundation
import SwiftUI

class DashboardViewModel: ObservableObject {
    @Published var spentUserCurrency: Decimal = 0
    @Published var budgetUserCurrency: Decimal = 0
    @Published var daysUntilNextDeposit: Int = 0

    struct CategoryData: Identifiable {
        var id: String { name }
        let name: String
        let amountMXN: Double
    }
    @Published var categoryData: [CategoryData] = [
        .init(name: "Renta", amountMXN: 4000),
        .init(name: "Supermercado", amountMXN: 2500),
        .init(name: "Internet", amountMXN: 500),
        .init(name: "Entretenimiento", amountMXN: 1000)
    ]

    struct ExpenseSummary: Identifiable {
        let id: String
        let title: String
        let date: Date
        let originalAmount: String
        let convertedAmount: String
        let isPaid: Bool
    }
    @Published var recentExpenses: [ExpenseSummary] = [
        .init(id: "1", title: "Cena en restaurante", date: Date(), originalAmount: "AUD 80.00", convertedAmount: "≈ MXN 912", isPaid: false),
        .init(id: "2", title: "Lavandería", date: Date().addingTimeInterval(-86400), originalAmount: "AUD 15.00", convertedAmount: "≈ MXN 171", isPaid: true),
        .init(id: "3", title: "Supermercado", date: Date().addingTimeInterval(-2 * 86400), originalAmount: "MXN 1200.00", convertedAmount: "MXN 1200", isPaid: true)
    ]

    var spentRatio: Double {
        guard budgetUserCurrency > 0 else { return 0 }
        let spent = NSDecimalNumber(decimal: spentUserCurrency).doubleValue
        let budget = NSDecimalNumber(decimal: budgetUserCurrency).doubleValue
        return min(1.0, spent / budget)
    }

    func update(using user: StoredUser?) {
        guard let user else {
            spentUserCurrency = 0
            budgetUserCurrency = 0
            daysUntilNextDeposit = 0
            return
        }

        let calendar = Calendar.current
        daysUntilNextDeposit = calendar.dateComponents([.day], from: Date(), to: user.fortnightDate).day ?? 0

        if let quincena = user.quincenas.first(where: { $0.active }) {
            spentUserCurrency = quincena.spent
            budgetUserCurrency = quincena.budgetAmount
        } else {
            spentUserCurrency = 0
            budgetUserCurrency = user.budgetValue
        }
    }
}
