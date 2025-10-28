//
//  AddTripRequirement.swift
//  KoalaCash
//
//  Created by Jesus Cedillo on 28/10/25.
//

import Foundation
import SwiftData

protocol AddTripRequirementProtocol {
    func addTrip(name: String, startDate: Date, endDate: Date?, currency: String, user: StoredUser, context: ModelContext) async -> Bool
}

class AddTripRequirement: AddTripRequirementProtocol {
    static let shared = AddTripRequirement()

    let travelRepository: TravelRepository

    init(travelRepository: TravelRepository = TravelRepository.shared) {
        self.travelRepository = travelRepository
    }
    
    func addTrip(name: String, startDate: Date, endDate: Date?, currency: String, user: StoredUser, context: ModelContext) async -> Bool {
            await travelRepository.addTrip(name: name, startDate: startDate, endDate: endDate, currency: currency, user: user, context: context)
        }
}
