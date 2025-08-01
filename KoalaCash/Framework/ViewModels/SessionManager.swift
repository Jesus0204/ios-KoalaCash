//
//  SessionManager.swift
//  KoalaCash
//
//  Created by Jesus Cedillo on 31/07/25.
//

import SwiftUI
import FirebaseAuth
import SwiftData

class SessionManager: ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var isLoading: Bool = true
    
    @Published var storedUser: StoredUser?
    
    @Published var messageAlert = ""
    @Published var showAlert = false
    
    private var authStateListenerHandle: AuthStateDidChangeListenerHandle?
    
    private var modelContext: ModelContext
    
    init(context: ModelContext) {
        self.modelContext = context
        setupAuthStateListener()
    }
    
    deinit {
        removeAuthStateListener()
    }
    
    private func setupAuthStateListener() {
        authStateListenerHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                self?.isAuthenticated = (user != nil)
                self?.isLoading = false
                self?.fetchStoredUser(for: user)
            }
        }
    }
    
    private func removeAuthStateListener() {
        if let handle = authStateListenerHandle {
            Auth.auth().removeStateDidChangeListener(handle)
            authStateListenerHandle = nil
        }
    }
    
    private func fetchStoredUser(for user: FirebaseAuth.User?) {
        guard let uid = user?.uid else {
            storedUser = nil
            return
        }
        
        let desc = FetchDescriptor<StoredUser>(predicate: #Predicate { $0.firebaseUID == uid })
        do {
            storedUser = try modelContext.fetch(desc).first
            print(storedUser?.firebaseUID)
        } catch {
            print("❌ Error al fetch de StoredUser:", error)
            storedUser = nil
        }
    }
    
    @MainActor
    func reloadStoredUser() {
        fetchStoredUser(for: Auth.auth().currentUser)
    }
    
    @MainActor
    func signOut() async {
        do {
            try Auth.auth().signOut()
            self.isAuthenticated = false
            self.storedUser = nil
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
}
