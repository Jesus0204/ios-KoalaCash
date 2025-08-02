//
//  AddExpenseViewModel.swift
//  KoalaCash
//
//  Created by Jesus Cedillo on 01/08/25.
//

import Foundation
import SwiftData

class AddExpenseViewModel: ObservableObject {
    @Published var nameValue: String = ""
    @Published var currencyValue: String = "MXN"
    @Published var categoryValue: String = "Renta"
    @Published var budgetValue: Decimal? = nil

    @Published var messageAlert = ""
    @Published var showAlert = false
    
    var addExpenseRequirement: AddExpenseRequirementProtocol

    init(addExpenseRequirement: AddExpenseRequirementProtocol = AddExpenseRequirement.shared) {
        self.addExpenseRequirement = addExpenseRequirement
    }
    
    @MainActor
    func guardarGasto(usuario: StoredUser, context: ModelContext) async {
        guard !nameValue.trimmingCharacters(in: .whitespaces).isEmpty else {
            messageAlert = "Por favor ingrese un nombre válido."
            showAlert = true
            return
        }
        
        guard let amount = budgetValue, amount > 0 else {
            messageAlert = "Por favor ingrese un monto válido."
            showAlert = true
            return
        }

        let guardado = await addExpenseRequirement.agregarGasto(name: nameValue, currency: currencyValue, amount: amount, category: categoryValue, user: usuario, context: context)

        if guardado {
            budgetValue = nil
            nameValue = ""
        } else {
            messageAlert = "Hubo un error al guardar el gasto. Favor de intentarlo de nuevo."
            showAlert = true
        }
    }
}
