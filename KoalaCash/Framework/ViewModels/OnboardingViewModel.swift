//
//  OnboardingViewModel.swift
//  KoalaCash
//
//  Created by Jesus Cedillo on 29/07/25.
//

import Foundation
import SwiftData

class OnboardingViewModel: ObservableObject {
    @Published var isOnboardingCompleted: Bool = false
    @Published var fortnightDate : Date = Date()
    @Published var currencyValue : String = "MXN"
    @Published var budgetValue : Decimal? = nil
    
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    @Published var isPasswordVisible: Bool = false
    @Published var isConfirmVisible: Bool = false
    
    @Published var nickname: String = ""
    
    // Creas dos variables más por si se comete un error
    @Published var messageAlert = ""
    @Published var showAlert = false
    
    var signUpRequirement: SignUpRequirementProtocol
    
    init(signUpRequirement: SignUpRequirementProtocol = SignUpRequirement.shared) {
        self.signUpRequirement = signUpRequirement
    }
    
    func isOnlyText(_ text: String) -> Bool {
        let regex = "^[\\p{L} ]+$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return predicate.evaluate(with: text)
    }
    
    func isNotOnlyNumbers(_ text: String) -> Bool {
        let regex = "^(?!\\d+$).+"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return predicate.evaluate(with: text)
    }
    
    func isNotOnlySpecialCharacters(_ text: String) -> Bool {
        let regex = "^(?=.*[A-Za-z0-9]).+$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return predicate.evaluate(with: text)
    }
    
    func isValidPassword(_ password: String) -> Bool {
        let regex = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[!@#$%^&*(),.?\":{}|<>]).+$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return predicate.evaluate(with: password)
    }
    
    func isValidEmail(_ email: String) -> Bool {
        let regex = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return predicate.evaluate(with: email)
    }
    
    @MainActor
    func validarDatosApp() {
        guard let presupuesto = budgetValue, presupuesto > 0 else {
            self.messageAlert = "Por favor ingrese un monto de presupuesto válido."
            self.showAlert = true
            return
          }
    }
    
    @MainActor
    func registrarUsuario(context: ModelContext) async {
        if self.email.isEmpty || self.nickname.isEmpty || self.password.isEmpty || self.confirmPassword.isEmpty {
            self.messageAlert = "Alguno de los campos está vacío. Favor de completarlos."
            self.showAlert = true
            return
        }
        
        if !isValidEmail(self.email) {
            self.messageAlert = "El correo electrónico proporcionado no es válido."
            self.showAlert = true
            return
        }
        
        if !isNotOnlyNumbers(self.nickname) {
            self.messageAlert = "Por favor ingrese un apodo válido. No se permiten caracteres especiales o números."
            self.showAlert = true
            return
        }

        if !isNotOnlySpecialCharacters(self.nickname) {
            self.messageAlert = "Por favor ingrese un apodo válido. No se permiten caracteres especiales o números."
            self.showAlert = true
            return
        }
        
        if self.password != self.confirmPassword {
            self.messageAlert = "Las contraseñas no son iguales. Favor de intentarlo de nuevo."
            self.showAlert = true
            return
        }
        
        if self.password.count < 8 {
            self.messageAlert = "La contraseña es demasiado corta. Debe tener al menos 8 caracteres."
            self.showAlert = true
            return
        }
        
        if !isValidPassword(self.password) {
            self.messageAlert = "La contraseña debe contener al menos una letra minúscula, una letra mayúscula, un número y un carácter especial."
            self.showAlert = true
            return
        }
        
        let usuarioNuevo = UserNuevo(email: self.email, password: self.password, nickname: self.nickname,
                                     fortnightDate: self.fortnightDate, currencyValue: self.currencyValue, budgetValue: self.budgetValue ?? 0)
        
        let responseCode = await self.signUpRequirement.registrarUsuario(UserDatos: usuarioNuevo, context: context)
        
        if responseCode == 406 {
            self.messageAlert = "La contraseña es demasiado corta. Debe tener al menos 6 caracteres."
            self.showAlert = true
        } else if responseCode == 405 {
            self.messageAlert = "El correo electrónico proporcionado no es válido."
            self.showAlert = true
        } else if responseCode != 201 {
            self.messageAlert = "Hubo un error al registrar al usuario. Favor de intentarlo de nuevo."
            self.showAlert = true
        }
    }
}
