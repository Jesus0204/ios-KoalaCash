//
//  SessionAPIService.swift
//  KoalaCash
//
//  Created by Jesus Cedillo on 31/07/25.
//

import Foundation
import FirebaseAuth
import Alamofire

class SessionAPIService {
    static let shared = SessionAPIService()
    
    let session = Session(configuration: {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 7.5 // Tiempo de espera de 7.5 segundos para la solicitud
        configuration.timeoutIntervalForResource = 15 // Tiempo de espera de 15 segundos para el recurso
        return configuration
    }())
    
    func registrarUsuario(UserDatos: UserNuevo) async -> Int? {
        do {
            // Crear el usuario en Firebase Authentication
            let authResult = try await Auth.auth().createUser(withEmail: UserDatos.email, password: UserDatos.password)
            
            // Obtener el UID de Firebase Authentication
            let firebaseUID = authResult.user.uid
            
            // Mandas el correo de verificación
            try await authResult.user.sendEmailVerification()
            
            return 201
        } catch let error as NSError {
            // Convertir el error a AuthErrorCode para manejar casos específicos
            if let authError = AuthErrorCode(rawValue: error.code) {
                switch authError {
                case .weakPassword:
                    print("Error: La contraseña es demasiado corta. Debe tener al menos 6 caracteres.")
                    return 406
                case .invalidEmail:
                    print("Error: El correo electrónico proporcionado no es válido.")
                    return 405
                default:
                    // Manejar otros errores de Firebase Authentication
                    print("Error al registrar en Firebase: \(error.localizedDescription)")
                }
            } else {
                // Manejar errores que no son de Firebase Authentication
                print("Error desconocido al registrar en Firebase: \(error.localizedDescription)")
            }
            return nil
        }
    }
    
    func iniciarSesion(UserDatos: User) async -> Int? {
        do {
            // Iniciar sesión en Firebase Authentication con el correo y la contraseña
            let authResult = try await Auth.auth().signIn(withEmail: UserDatos.username, password: UserDatos.password)
            
            // Obtener el ID Token del usuario autenticado
            let idToken = try await authResult.user.getIDToken()
            
            return 201
        } catch {
            // Manejo de errores de inicio de sesión
            print("Error al iniciar sesión: \(error.localizedDescription)")
            return 1 // Error, devuelve nil o el código de error correspondiente
        }
    }
    
    func emailRestablecerContraseña(email: String) async -> Bool {
        do {
            try await Auth.auth().sendPasswordReset(withEmail: email)
            return true
        } catch {
            print("Restablecer contraseña fallida: \(error.localizedDescription)")
            return false
        }
    }
}
