//
//  ResetPasswordsViewModel.swift
//  KoalaCash
//
//  Created by Jesus Cedillo on 01/08/25.
//

import Foundation

class RestablecerContraseñaViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var messageAlert = ""
    @Published var showAlert = false
    @Published var alertSuccess = false
    
    var restablecerContraseñaRequirement: RestablecerContraseñaRequirement

    init(restablecerContraseñaRequirement: RestablecerContraseñaRequirement = RestablecerContraseñaRequirement.shared) {
        self.restablecerContraseñaRequirement = restablecerContraseñaRequirement
    }
    
    @MainActor
    func emailRestablecerContraseña() async {
        if self.email.isEmpty {
            self.messageAlert = "Correo vacío. Favor de intentarlo de nuevo."
            self.showAlert = true
            self.alertSuccess = false
            return
        }
        
        let emailSent = await restablecerContraseñaRequirement.emailRestablecerContraseña(email: self.email)
        
        if emailSent == true {
            self.showAlert = true
            self.messageAlert = "¡El enlace ha sido enviado!"
            self.alertSuccess = true
        } else {
            self.showAlert = true
            self.messageAlert = "Hubo un error al enviar el enlace. Favor de intentarlo de nuevo."
            self.alertSuccess = false
        }
    }
}
