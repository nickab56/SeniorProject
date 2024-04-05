//
//  AuthViewModel.swift
//  backblog
//
//  Created by Jake Buhite on 2/12/24.
//

import SwiftUI
import CoreData

class AuthViewModel: ObservableObject {
    @Published var isLoggedInToSocial: Bool = false
    @Published var signupMessage: String = ""
    @Published var loginMessage: String = ""
    @Published var signupSuccessful: Bool = false
    @Published var messageColor: Color = .red
    
    private var fb: FirebaseProtocol
    private var userRepo: UserRepository
    private var logRepo: LogRepository
    
    init(fb: FirebaseProtocol) {
        self.fb = fb
        self.userRepo = UserRepository(fb: fb)
        self.logRepo = LogRepository(fb: fb)
        getAuthChange()
    }
    
    /**
     Initiates the signup process with the provided user information.

     - Parameters:
       - email: The user's email address.
       - password: The user's chosen password.
       - displayName: The user's chosen display name.
     */
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
                    
                    syncLocalLogsToDB(userId: result)
                } catch {
                    signupMessage = "Signup Failed: \(error.localizedDescription)"
                    messageColor = Color.red
                }
            }
        }
    }
    
    /**
     Syncs local logs with the database, transferring any locally stored logs to the server.
     */
    func syncLocalLogsToDB(userId: String) {
        DispatchQueue.main.async { [self] in
            Task {
                let logs = getLocalLogs()
                
                do {
                    _ = try await withThrowingTaskGroup(of: Bool.self) { group in
                        for (i, e) in logs.enumerated() {
                            group.addTask {
                                do {
                                    let movieIds = (e.movie_ids?.allObjects as? [LocalMovieData])?.compactMap { $0.movie_id } ?? []
                                    let watchedIds = (e.watched_ids?.allObjects as? [LocalMovieData])?.compactMap { $0.movie_id } ?? []
                                    return try await self.logRepo.addLog(name: e.name ?? "Log",
                                                                         ownerId: userId,
                                                                         priority: i,
                                                                         creationDate: e.creation_date ?? String(currentTimeInMS()),
                                                                         movieIds: movieIds,
                                                                         watchedIds: watchedIds).get()
                                } catch {
                                    print("Error updating userId: \(error)")
                                    throw error
                                }
                            }
                        }
                        
                        for try await result in group {
                            if (!result) {
                                throw FirebaseError.failedTransaction
                            }
                        }
                            
                        return true
                    }
                } catch {
                    print("Error syncing local logs to DB")
                }
                
                // Logs transferred, delete local logs
                resetAllLogs()
            }
        }
    }
    
    /**
     Fetches all logs stored locally.

     - Returns: An array of `LocalLogData` objects representing each local log.
     */
    private func getLocalLogs() -> [LocalLogData] {
        let context = PersistenceController.shared.container.viewContext

        let fetchRequest: NSFetchRequest<LocalLogData> = LocalLogData.fetchRequest()
        do {
            let items = try context.fetch(fetchRequest)
            return items
        } catch let error as NSError {
            print("Error resetting logs: \(error), \(error.userInfo)")
        }
        return []
    }
    
    /**
     Resets all logs stored locally, clearing the local database of log entries.
     */
    private func resetAllLogs() {
        let context = PersistenceController.shared.container.viewContext

        let fetchRequest: NSFetchRequest<LocalLogData> = LocalLogData.fetchRequest()
        do {
            let items = try context.fetch(fetchRequest)
            for item in items {
                context.delete(item)
            }
            try context.save()
        } catch let error as NSError {
            print("Error resetting logs: \(error), \(error.userInfo)")
        }
    }
    
    /**
     Attempts to log in a user with the provided credentials.

     - Parameters:
       - email: The user's email address.
       - password: The user's password.
     */
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
                    let msg = "Failed to login. Please check your email and password" 
                    /*if (error.localizedDescription.contains("malformed")) {
                        "Incorrect email or password"
                    } else {
                        error.localizedDescription
                    }*/
                    loginMessage = msg
                    messageColor = Color.red
                }
            }
        }
    }
    
    func getAuthChange() {
        fb.getAuth()?.addStateDidChangeListener { auth, user in
            if (auth.currentUser != nil) {
                self.isLoggedInToSocial = true
            }
        }
    }
}
