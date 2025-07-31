//
//  LoginRequirement.swift
//  KoalaCash
//
//  Created by Jesus Cedillo on 31/07/25.
//

import Foundation

protocol LoginRequirementProtocol {
    func iniciarSesion(UserDatos: User) async -> Int?
}

class LoginRequirement: LoginRequirementProtocol {
    
    // Singleton para que lo use el Requirement
    static let shared = LoginRequirement()
    
    // La variable inmutable es de tipo Pokemon Repository
    let sessionRepository: SessionRepository
    
    // Inicializas la instancia con el repositorio que acaba se crearse
    init(sessionRepository: SessionRepository = SessionRepository.shared) {
        self.sessionRepository = sessionRepository
    }
    
    func iniciarSesion(UserDatos: User) async -> Int? {
        return await sessionRepository.iniciarSesion(UserDatos: UserDatos)
    }
    
}
