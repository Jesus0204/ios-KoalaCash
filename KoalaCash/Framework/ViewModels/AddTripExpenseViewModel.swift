//
//  AddTripExpenseViewModel.swift
//  KoalaCash
//
//  Created by Jesus Cedillo on 28/10/25.
//

import Foundation
import SwiftData

class AddTripExpenseViewModel: ObservableObject {
    @Published var nameValue: String = ""
    @Published var currencyValue: String = "MXN"
    @Published var categoryValue: String = "Transporte"
    @Published var amountValue: Decimal? = nil
    @Published var isShared: Bool = false
    @Published var sharedCount: Int = 2
    @Published var includeInBudget: Bool = false

    @Published var messageAlert: String = ""
    @Published var showAlert: Bool = false

    private let addExpenseRequirement: AddTripExpenseRequirementProtocol

    init(addExpenseRequirement: AddTripExpenseRequirementProtocol = AddTripExpenseRequirement.shared) {
        self.addExpenseRequirement = addExpenseRequirement
    }

    @MainActor
    func guardarGasto(trip: Trip, context: ModelContext) async {
        let trimmedName = nameValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            messageAlert = "Por favor ingresa un nombre válido."
            showAlert = true
            return
        }

        guard let amount = amountValue, amount > 0 else {
            messageAlert = "Por favor ingresa un monto válido."
            showAlert = true
            return
        }

        let dividedBy = isShared ? sharedCount : 1

        let guardado = await addExpenseRequirement.addExpense(to: trip,
                                                              name: trimmedName,
                                                              currency: currencyValue,
                                                              amount: amount,
                                                              category: categoryValue,
                                                              dividedBy: dividedBy,
                                                              includeInBudget: includeInBudget,
                                                              context: context)

        if guardado {
            nameValue = ""
            amountValue = nil
            isShared = false
            sharedCount = 2
            currencyValue = trip.baseCurrency
            includeInBudget = false
        } else {
            messageAlert = "Hubo un error al guardar el gasto. Intenta nuevamente."
            showAlert = true
        }
    }
}
