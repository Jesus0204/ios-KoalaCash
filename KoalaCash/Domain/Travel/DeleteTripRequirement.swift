//
//  DeleteTripRequirement.swift
//  KoalaCash
//
//  Created by Jesus Cedillo on 28/10/25.
//

import Foundation
import SwiftData

protocol DeleteTripRequirementProtocol {
    func deleteTrip(tripID: String, context: ModelContext) async -> Bool
}

class DeleteTripRequirement: DeleteTripRequirementProtocol {
    static let shared = DeleteTripRequirement()

    let travelRepository: TravelRepository

    init(travelRepository: TravelRepository = TravelRepository.shared) {
        self.travelRepository = travelRepository
    }
    
    func deleteTrip(tripID: String, context: ModelContext) async -> Bool {
        await travelRepository.deleteTrip(tripID: tripID, context: context)
    }
}
