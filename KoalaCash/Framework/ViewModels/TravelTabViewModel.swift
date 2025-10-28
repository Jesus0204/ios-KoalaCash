//
//  TravelTabViewModel.swift
//  KoalaCash
//
//  Created by Jesus Cedillo on 28/10/25.
//

import Foundation
import SwiftUI
import SwiftData

class TravelTabViewModel: ObservableObject {
    struct TripItem: Identifiable {
        let id: String
        let name: String
        let dateRange: String
        let currency: String
        let totalSpent: String
        let userTotalSpent: String?
        let isActive: Bool
    }

    struct ActiveTripSummary {
        let id: String
        let title: String
        let baseAmount: String
        let baseCurrencyCode: String
        let userAmount: String?
        let userCurrencyCode: String?
        let dateRange: String
        
        var showsUserAmount: Bool { userAmount != nil }
    }

    @Published var trips: [TripItem] = []
    @Published var activeTrip: ActiveTripSummary?

    @Published var showDeleteAlert: Bool = false
    @Published var pendingDeleteID: String?

    private let deleteRequirement: DeleteTripRequirementProtocol

    init(deleteRequirement: DeleteTripRequirementProtocol = DeleteTripRequirement.shared) {
        self.deleteRequirement = deleteRequirement
    }

    func update(using user: StoredUser?) {
        guard let user else {
            trips = []
            activeTrip = nil
            return
        }

        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 2
        
        let userCurrency = user.currencyValue

        let userFormatter = NumberFormatter()
        userFormatter.numberStyle = .currency
        userFormatter.maximumFractionDigits = 2
        userFormatter.currencyCode = userCurrency
        userFormatter.currencySymbol = userCurrency.currencySymbol

        trips = user.trips.sorted(by: { $0.startDate > $1.startDate }).map { trip in
            formatter.currencyCode = trip.baseCurrency
            formatter.currencySymbol = trip.baseCurrency.currencySymbol
            let total = NSDecimalNumber(decimal: trip.totalConvertedAmount)
            let amount = formatter.string(from: total) ?? "\(trip.baseCurrency.currencySymbol)\(total)"
            
            
            var userAmountText: String? = nil
            if trip.baseCurrency != userCurrency {
                let userTotal = NSDecimalNumber(decimal: trip.totalUserConvertedAmount)
                userAmountText = userFormatter.string(from: userTotal) ?? "\(userCurrency.currencySymbol)\(userTotal)"
            }

            return TripItem(
                id: trip.tripID.uuidString,
                name: trip.name,
                dateRange: trip.dateRangeText,
                currency: trip.baseCurrency,
                totalSpent: amount,
                userTotalSpent: userAmountText,
                isActive: trip.isActive
            )
        }

        if let current = user.trips.first(where: { $0.isActive }) {
            formatter.currencyCode = current.baseCurrency
            formatter.currencySymbol = current.baseCurrency.currencySymbol
            let total = NSDecimalNumber(decimal: current.totalConvertedAmount)
            let amount = formatter.string(from: total) ?? "\(current.baseCurrency.currencySymbol)\(total)"
            
            var userAmountText: String? = nil
            var userCurrencyCode: String? = nil
            if current.baseCurrency != userCurrency {
                let userTotal = NSDecimalNumber(decimal: current.totalUserConvertedAmount)
                userAmountText = userFormatter.string(from: userTotal) ?? "\(userCurrency.currencySymbol)\(userTotal)"
                userCurrencyCode = userCurrency
            }

            activeTrip = ActiveTripSummary(id: current.tripID.uuidString,
                                           title: current.name,
                                           baseAmount: amount,
                                           baseCurrencyCode: current.baseCurrency,
                                           userAmount: userAmountText,
                                           userCurrencyCode: userCurrencyCode,
                                           dateRange: current.dateRangeText)
        } else {
            activeTrip = nil
        }
    }

    @MainActor
    func deleteTrip(context: ModelContext, user: StoredUser?) async {
        guard let id = pendingDeleteID else { return }
        let deleted = await deleteRequirement.deleteTrip(tripID: id, context: context)
        if deleted {
            update(using: user)
        }
        pendingDeleteID = nil
        showDeleteAlert = false
    }
}
