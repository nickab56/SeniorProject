//
//  AuthViewModel.swift
//  backblog
//
//  Created by Jake Buhite on 2/12/24.
//

import SwiftUI

class AuthViewModel: ObservableObject {
    @Published var isLoggedInToSocial: Bool = false
    @Published var signupMessage: String = ""
    @Published var loginMessage: String = ""
    @Published var signupSuccessful: Bool = false
    @Published var messageColor: Color = .red
    
    let fb: FirebaseService = FirebaseService()
    private var userRepo: UserRepository
    
    init() {
        self.userRepo = UserRepository(fb: fb)
    }
    
    func attemptSignup(email: String, password: String, displayName: String) {
        DispatchQueue.main.async { [self] in
            Task {
                do {
                    // Check if username already exists
                    let exists = try await userRepo.usernameExists(username: displayName).get()
                    
                    if (exists) {
                        signupMessage = "Username already exists"
                        messageColor = Color.red
                        return
                    }
                    
                    // Register
                    let result = try await fb.register(email: email, password: password).get()
                    
                    // Store additional user data in firestore
                    _ = try await userRepo.addUser(userId: result, username: displayName, avatarPreset: 1).get()
                    
                    // Update status
                    signupSuccessful = true
                    signupMessage = "Signup Successful"
                    messageColor = Color.green
                } catch {
                    signupMessage = "Signup Failed: \(error.localizedDescription)"
                    messageColor = Color.red
                }
            }
        }
    }
    
    func attemptLogin(email: String, password: String) {
        DispatchQueue.main.async { [self] in
            Task {
                do {
                    _ = try await fb.login(email: email, password: password).get()
                    loginMessage = "Login Successful, redirecting..."
                    messageColor = Color.green
                    
                    // Add a short delay to display the success message before changing the state
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [self] in
                        // Now change the isLoggedInToSocial to trigger the redirection
                        isLoggedInToSocial = true
                    }
                } catch {
                    let msg = if (error.localizedDescription.contains("malformed")) {
                        "Incorrect email or password"
                    } else {
                        error.localizedDescription
                    }
                    loginMessage = msg
                    messageColor = Color.red
                }
            }
        }
    }
}
