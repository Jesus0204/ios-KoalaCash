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
        let isActive: Bool
    }

    struct ActiveTripSummary {
        let title: String
        let amount: String
        let dateRange: String
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

        trips = user.trips.sorted(by: { $0.startDate > $1.startDate }).map { trip in
            formatter.currencyCode = trip.baseCurrency
            formatter.currencySymbol = trip.baseCurrency.currencySymbol
            let total = NSDecimalNumber(decimal: trip.totalConvertedAmount)
            let amount = formatter.string(from: total) ?? "\(trip.baseCurrency.currencySymbol)\(total)"
            return TripItem(
                id: trip.tripID.uuidString,
                name: trip.name,
                dateRange: trip.dateRangeText,
                currency: trip.baseCurrency,
                totalSpent: amount,
                isActive: trip.isActive
            )
        }

        if let current = user.trips.first(where: { $0.isActive }) {
            formatter.currencyCode = current.baseCurrency
            formatter.currencySymbol = current.baseCurrency.currencySymbol
            let total = NSDecimalNumber(decimal: current.totalConvertedAmount)
            let amount = formatter.string(from: total) ?? "\(current.baseCurrency.currencySymbol)\(total)"
            activeTrip = ActiveTripSummary(title: current.name, amount: amount, dateRange: current.dateRangeText)
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
