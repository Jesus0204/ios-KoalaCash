//
//  ResetPasswordRequirement.swift
//  KoalaCash
//
//  Created by Jesus Cedillo on 01/08/25.
//

import Foundation

// Creas el protocolo de la historia de usuario
protocol RestablecerContraseñaRequirementProtocol {
    func emailRestablecerContraseña(email: String) async -> Bool
}

class RestablecerContraseñaRequirement: RestablecerContraseñaRequirementProtocol {
    
    // Singleton para que lo use el Requirement
    static let shared = RestablecerContraseñaRequirement()
    
    // La variable inmutable es de tipo Pokemon Repository
    let sessionRepository: SessionRepository
    
    // Inicializas la instancia con el repositorio que acaba se crearse
    init(sessionRepository: SessionRepository = SessionRepository.shared) {
        self.sessionRepository = sessionRepository
    }
    
    func emailRestablecerContraseña(email: String) async -> Bool {
        return await sessionRepository.emailRestablecerContraseña(email: email)
    }
    
}
