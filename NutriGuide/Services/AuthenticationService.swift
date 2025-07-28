//
//  AuthenticationService.swift
//  NutriGuide
//
//  Created by Hrigved Khatavkar on 4/3/25.
//
//
import Foundation
import Firebase
@preconcurrency import FirebaseAuth
import SwiftUI

class AuthenticationService: ObservableObject {
    @Published var user: User?
    @Published var isAuthenticated = false
    
    static let shared = AuthenticationService()
    
    init() {
        checkAuthState()
    }
    
    private func checkAuthState() {
        user = Auth.auth().currentUser
        isAuthenticated = user != nil
    }
    
    func signIn(email: String, password: String) async throws {
        let authResult = try await Auth.auth().signIn(withEmail: email, password: password)
        DispatchQueue.main.async {
            self.user = authResult.user
            self.isAuthenticated = true
        }
    }
    
    func createAccount(email: String, password: String, name: String) async throws {
        let authResult = try await Auth.auth().createUser(withEmail: email, password: password)
        
        let changeRequest = authResult.user.createProfileChangeRequest()
        changeRequest.displayName = name
        try await changeRequest.commitChanges()
        
        DispatchQueue.main.async {
            self.user = authResult.user
            self.isAuthenticated = true
        }
    }
    
    func signOut() throws {
        try Auth.auth().signOut()
        DispatchQueue.main.async {
            self.user = nil
            self.isAuthenticated = false
        }
    }
    
    func resetPassword(email: String) async throws {
        try await Auth.auth().sendPasswordReset(withEmail: email)
    }
    
    func signInAnonymously() async throws {
        let authResult = try await Auth.auth().signInAnonymously()
        DispatchQueue.main.async {
            self.user = authResult.user
            self.isAuthenticated = true
        }
    }
}
