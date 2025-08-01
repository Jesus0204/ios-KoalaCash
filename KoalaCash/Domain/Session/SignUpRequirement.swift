//
//  SignUpRequierement}.swift
//  KoalaCash
//
//  Created by Jesus Cedillo on 31/07/25.
//

import Foundation
import SwiftData

protocol SignUpRequirementProtocol {
    func registrarUsuario(UserDatos: UserNuevo, context: ModelContext) async -> Int?
}

class SignUpRequirement: SignUpRequirementProtocol {
    
    // Singleton para que lo use el Requirement
    static let shared = SignUpRequirement()
    
    let sessionRepository: SessionRepository
    
    // Inicializas la instancia con el repositorio que acaba se crearse
    init(sessionRepository: SessionRepository = SessionRepository.shared) {
        self.sessionRepository = sessionRepository
    }
    
    func registrarUsuario(UserDatos: UserNuevo, context: ModelContext) async -> Int? {
        return await sessionRepository.registrarUsuario(UserDatos: UserDatos, context: context)
    }
}
