//
//  SignUpRequierement}.swift
//  KoalaCash
//
//  Created by Jesus Cedillo on 31/07/25.
//

import Foundation

protocol SignUpRequirementProtocol {
    func registrarUsuario(UserDatos: UserNuevo) async -> Int?
}

class SignUpRequirement: SignUpRequirementProtocol {
    
    // Singleton para que lo use el Requirement
    static let shared = SignUpRequirement()
    
    let sessionRepository: SessionRepository
    
    // Inicializas la instancia con el repositorio que acaba se crearse
    init(sessionRepository: SessionRepository = SessionRepository.shared) {
        self.sessionRepository = sessionRepository
    }
    
    func registrarUsuario(UserDatos: UserNuevo) async -> Int? {
        return await sessionRepository.registrarUsuario(UserDatos: UserDatos)
    }
}
