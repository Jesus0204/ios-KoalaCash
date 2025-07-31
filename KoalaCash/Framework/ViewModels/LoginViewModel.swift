//
//  LoginViewModel.swift
//  KoalaCash
//
//  Created by Jesus Cedillo on 01/08/25.
//

import Foundation
import FirebaseAuth

// Tipo observable para que la interfaz sepa de cambios
class LoginViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isPasswordVisible: Bool = false
    
    @Published var messageAlert = ""
    @Published var showAlert = false
    
    var loginRequirement: LoginRequirementProtocol
        
    init(loginRequirement: LoginRequirementProtocol = LoginRequirement.shared) {
        self.loginRequirement = loginRequirement
    }
    
    @MainActor
    func iniciarSesion() async {
        
        if self.email.isEmpty || self.password.isEmpty {
            self.messageAlert = "Correo vacío o contraseña vacía. Favor de intentarlo de nuevo."
            self.showAlert = true
            return
        }
        
        let UserData = User(username: self.email, password: self.password)
        
        let responseStatus = await self.loginRequirement.iniciarSesion(UserDatos: UserData)
        
        if responseStatus == 1 {
            self.messageAlert = "El usuario o contraseña ingresada es incorrecta. Favor de intentarlo de nuevo."
            self.showAlert = true
        } else if responseStatus != 200 {
            self.messageAlert = "Hubo un error al procesar el inicio se sesión. Favor de intentarlo de nuevo."
            self.showAlert = true
        }
    }
}
