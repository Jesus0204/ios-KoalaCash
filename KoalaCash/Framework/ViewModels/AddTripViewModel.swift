//
//  AddTripViewModel.swift
//  KoalaCash
//
//  Created by Jesus Cedillo on 28/10/25.
//

import Foundation
import SwiftData

class AddTripViewModel: ObservableObject {
    @Published var nameValue: String = ""
    @Published var startDate: Date = Date()
    @Published var endDate: Date? = nil
    @Published var currencyValue: String = "MXN"
    
    @Published var messageAlert: String = ""
    @Published var showAlert: Bool = false

    private let addTripRequirement: AddTripRequirementProtocol

    init(addTripRequirement: AddTripRequirementProtocol = AddTripRequirement.shared) {
        self.addTripRequirement = addTripRequirement
    }
    
    @MainActor
    func guardarViaje(usuario: StoredUser, context: ModelContext) async {
        let trimmedName = nameValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            messageAlert = "Por favor ingresa un nombre válido."
            showAlert = true
            return
        }

        if let end = endDate, end < startDate {
            messageAlert = "La fecha de fin debe ser posterior a la fecha de inicio."
            showAlert = true
            return
        }
        
        let guardado = await addTripRequirement.addTrip(name: trimmedName, startDate: startDate, endDate: endDate, currency: currencyValue, user: usuario, context: context)

        if guardado {
            nameValue = ""
            startDate = Date()
            endDate = nil
            currencyValue = usuario.currencyValue
        } else {
            messageAlert = "Hubo un error al guardar el viaje. Intenta nuevamente."
            showAlert = true
        }
    }
}
