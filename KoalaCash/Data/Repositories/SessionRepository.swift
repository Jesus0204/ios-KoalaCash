//
//  SessionRepository.swift
//  KoalaCash
//
//  Created by Jesus Cedillo on 31/07/25.
//

import Foundation
import SwiftData

protocol SessionAPIProtocol {
    func registrarUsuario(UserDatos: UserNuevo, context: ModelContext) async -> Int?
}

class SessionRepository: SessionAPIProtocol {
    
    // Singleton para que cada requerimiento pueda acceder al mismo archivo y clase (repositiorio con funciones de llamadas API
    static let shared = SessionRepository()
    
    // Se crea la variable tipo NetworkAPIService con la librería Alamofire
    let sessionService: SessionAPIService
    
    // Se inicializa con la variable singleton
    init(sessionService: SessionAPIService = SessionAPIService.shared) {
            self.sessionService = sessionService
        }
    
    func registrarUsuario(UserDatos: UserNuevo, context: ModelContext) async -> Int? {
        return await sessionService.registrarUsuario(UserDatos: UserDatos, context: context)
    }
    
    func iniciarSesion(UserDatos: User) async -> Int? {
        return await sessionService.iniciarSesion(UserDatos: UserDatos)
    }
    
    func emailRestablecerContraseña(email: String) async -> Bool {
        return await sessionService.emailRestablecerContraseña(email: email)
    }
}
