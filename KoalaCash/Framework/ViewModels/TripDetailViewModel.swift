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
    
    struct CategoryData: Identifiable {
        let id: String
        let name: String
        let amount: Double
        let formattedAmount: String
    }


    @Published var tripName: String = ""
    @Published var dateRange: String = ""
    @Published var totalSpentText: String = ""
    @Published var currencyCode: String = "MXN"
    @Published var totalUserSpentText: String? = nil
    @Published var userCurrencyCode: String = "MXN"
    @Published var categoryData: [CategoryData] = []
    @Published var showsUserTotal: Bool = false
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
            totalUserSpentText = nil
            userCurrencyCode = "MXN"
            showsUserTotal = false
            categoryData = []
            return
        }

        currencyCode = trip.baseCurrency
        userCurrencyCode = user.currencyValue
        tripName = trip.name
        dateRange = trip.dateRangeText

        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 2
        formatter.currencyCode = trip.baseCurrency
        formatter.currencySymbol = trip.baseCurrency.currencySymbol
        
        let userFormatter = NumberFormatter()
        userFormatter.numberStyle = .currency
        userFormatter.maximumFractionDigits = 2
        userFormatter.currencyCode = user.currencyValue
        userFormatter.currencySymbol = user.currencyValue.currencySymbol

        let total = NSDecimalNumber(decimal: trip.totalConvertedAmount)
        totalSpentText = formatter.string(from: total) ?? "\(trip.baseCurrency.currencySymbol)\(total)"
        
        if trip.baseCurrency != user.currencyValue {
            let userTotal = NSDecimalNumber(decimal: trip.totalUserConvertedAmount)
            totalUserSpentText = userFormatter.string(from: userTotal) ?? "\(user.currencyValue.currencySymbol)\(userTotal)"
            showsUserTotal = true
        } else {
            totalUserSpentText = nil
            showsUserTotal = false
        }


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
        
        if trip.expenses.isEmpty {
            categoryData = []
        } else {
            var totalsByCategory: [String: Decimal] = [:]
            for expense in trip.expenses {
                totalsByCategory[expense.category, default: 0] += expense.totalUserConvertedAmount
            }

            categoryData = totalsByCategory
                .sorted { $0.value > $1.value }
                .map { key, value in
                    let amountNumber = NSDecimalNumber(decimal: value)
                    let formatted = userFormatter.string(from: amountNumber) ?? "\(user.currencyValue.currencySymbol)\(amountNumber)"
                    return CategoryData(id: key, name: key, amount: amountNumber.doubleValue, formattedAmount: formatted)
                }
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
