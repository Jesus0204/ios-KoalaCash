//
//  TripDetailViewModel.swift
//  KoalaCash
//
//  Created by Jesus Cedillo on 28/10/25.
//

import Foundation
import SwiftData

class TripDetailViewModel: ObservableObject {
    struct ExpenseItem: Identifiable {
        let id: String
        let name: String
        let category: String
        let date: Date
        let originalAmount: String
        let convertedAmount: String
        let dividedBy: Int
        let totalOriginalAmount: String
    }

    @Published var tripName: String = ""
    @Published var dateRange: String = ""
    @Published var totalSpentText: String = ""
    @Published var currencyCode: String = "MXN"
    @Published var expenses: [ExpenseItem] = []

    @Published var showDeleteAlert: Bool = false
    @Published var pendingDeleteExpenseID: String?

    private let deleteRequirement: DeleteTripExpenseRequirementProtocol

    init(deleteRequirement: DeleteTripExpenseRequirementProtocol = DeleteTripExpenseRequirement.shared) {
        self.deleteRequirement = deleteRequirement
    }

    func update(using user: StoredUser?, tripID: String) {
        guard
            let user,
            let uuid = UUID(uuidString: tripID),
            let trip = user.trips.first(where: { $0.tripID == uuid })
        else {
            expenses = []
            tripName = ""
            dateRange = ""
            totalSpentText = ""
            return
        }

        currencyCode = trip.baseCurrency
        tripName = trip.name
        dateRange = trip.dateRangeText

        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 2
        formatter.currencyCode = trip.baseCurrency
        formatter.currencySymbol = trip.baseCurrency.currencySymbol

        let total = NSDecimalNumber(decimal: trip.totalConvertedAmount)
        totalSpentText = formatter.string(from: total) ?? "\(trip.baseCurrency.currencySymbol)\(total)"

        expenses = trip.expenses
            .sorted(by: { $0.datePurchase > $1.datePurchase })
            .map { expense in
                formatter.currencyCode = expense.originalCurrency
                formatter.currencySymbol = expense.originalCurrency.currencySymbol
                let totalOriginal = NSDecimalNumber(decimal: expense.totalOriginalAmount)
                let perPersonOriginal = NSDecimalNumber(decimal: expense.originalAmount)

                let convertedFormatter = NumberFormatter()
                convertedFormatter.numberStyle = .currency
                convertedFormatter.maximumFractionDigits = 2
                convertedFormatter.currencyCode = expense.convertedCurrency
                convertedFormatter.currencySymbol = expense.convertedCurrency.currencySymbol

                return ExpenseItem(
                    id: expense.travelExpenseID.uuidString,
                    name: expense.name,
                    category: expense.category,
                    date: expense.datePurchase,
                    originalAmount: formatter.string(from: perPersonOriginal) ?? "\(expense.originalCurrency.currencySymbol)\(perPersonOriginal)",
                    convertedAmount: convertedFormatter.string(from: NSDecimalNumber(decimal: expense.convertedAmount)) ?? "\(expense.convertedCurrency.currencySymbol)\(expense.convertedAmount)",
                    dividedBy: expense.dividedBy,
                    totalOriginalAmount: formatter.string(from: totalOriginal) ?? "\(expense.originalCurrency.currencySymbol)\(totalOriginal)"
                )
            }
    }

    func trip(for user: StoredUser?, id: String) -> Trip? {
        guard let user, let uuid = UUID(uuidString: id) else { return nil }
        return user.trips.first(where: { $0.tripID == uuid })
    }

    @MainActor
    func deleteExpense(context: ModelContext, user: StoredUser?, tripID: String) async {
        guard let id = pendingDeleteExpenseID else { return }
        let deleted = await deleteRequirement.deleteExpense(expenseID: id, context: context)
        if deleted {
            update(using: user, tripID: tripID)
        }
        pendingDeleteExpenseID = nil
        showDeleteAlert = false
    }
}
