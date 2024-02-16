//
//  SocialViewModel.swift
//  backblog
//
//  Created by Jake Buhite on 2/12/24.
//

import Foundation

class SocialViewModel: ObservableObject {
    @Published var logs: [LogData] = []
    @Published var selectedTab = "Logs"
    @Published var userData: UserData?
    @Published var friends: [UserData] = []
    @Published var friendRequests: [(FriendRequestData, UserData)] = []
    @Published var logRequests: [(LogRequestData, UserData)] = []
    
    // Notification message
    @Published var showingNotification = false
    @Published var notificationMessage = ""
    @Published var showingSendFriendReqSheet = false
    
    // Settings
    @Published var isUnauthorized = false
    @Published var avatarSelection = 1
   
    private let fb: FirebaseProtocol
    private let userRepo: UserRepository
    private let logRepo: LogRepository
    private let friendRepo: FriendRepository
    
    init(fb: FirebaseProtocol) {
        self.fb = fb
        self.userRepo = UserRepository(fb: fb)
        self.logRepo = LogRepository(fb: fb)
        self.friendRepo = FriendRepository(fb: fb)
        fetchUserData()
        fetchLogs()
        fetchFriends()
        fetchFriendRequests()
        fetchLogRequests()
    }
   
    func fetchUserData() {
        DispatchQueue.main.async { [self] in
            Task {
                guard let userId = fb.getUserId() else {
                    return
                }
                do {
                    let result = try await userRepo.getUser(userId:userId).get()
                    userData = result
                    avatarSelection = userData?.avatarPreset ?? 1
                } catch {
                    print("Error fetching user: \(error.localizedDescription)")
                }
            }
        }
    }
   
    func fetchLogs() {
        DispatchQueue.main.async { [self] in
            Task {
                guard let userId = fb.getUserId() else {
                    return
                }
                do {
                    let result = try await logRepo.getLogs(userId: userId, showPrivate: false).get()
                    logs = result
                } catch {
                    print("Error fetching logs: \(error.localizedDescription)")
                }
            }
        }
    }
   
    func fetchFriends() {
        DispatchQueue.main.async { [self] in
            Task {
                guard let userId = fb.getUserId() else {
                    return
                }
                do {
                    let result = try await friendRepo.getFriends(userId: userId).get()
                    friends = result.sorted { ($0.userId ?? "") > ($1.userId ?? "") }
                } catch {
                    print("Error fetching friends: \(error.localizedDescription)")
                }
            }
        }
    }
   
    func fetchLogRequests() {
        DispatchQueue.main.async { [self] in
            Task {
                guard let userId = fb.getUserId() else {
                    return
                }
                do {
                    let logReq = try await userRepo.getLogRequests(userId: userId).get() // Returns [LogRequestData]
                    
                    let result: [(LogRequestData, UserData)] = try await withThrowingTaskGroup(of: (LogRequestData, UserData).self) { group in
                        for req in logReq {
                            group.addTask { [self] in
                                do {
                                    let user = try await userRepo.getUser(userId: req.senderId ?? "").get()
                                    return (req, user)
                                } catch {
                                    throw error
                                }
                            }
                        }
                        
                        var resultArr: [(LogRequestData, UserData)] = []
                        
                        for try await result in group {
                            resultArr.append(result)
                        }
                        
                        return resultArr
                    }
                    logRequests = result
                } catch {
                    print("Error fetching log requests: \(error.localizedDescription)")
                }
            }
        }
    }
   
    func fetchFriendRequests() {
        DispatchQueue.main.async { [self] in
            Task {
                guard let userId = fb.getUserId() else {
                    return
                }
                do {
                    let friendReq = try await userRepo.getFriendRequests(userId: userId).get() // Returns [FriendRequestData]
                    
                    let result: [(FriendRequestData, UserData)] = try await withThrowingTaskGroup(of: (FriendRequestData, UserData).self) { group in
                        for req in friendReq {
                            group.addTask { [self] in
                                do {
                                    let user = try await userRepo.getUser(userId: req.senderId ?? "").get()
                                    return (req, user)
                                } catch {
                                    throw error
                                }
                            }
                        }
                        
                        var resultArr: [(FriendRequestData, UserData)] = []
                        
                        for try await result in group {
                            resultArr.append(result)
                        }
                        
                        return resultArr
                    }
                    
                    friendRequests = result
                } catch {
                    print("Error fetching log requests: \(error.localizedDescription)")
                }
            }
        }
    }
   
    func updateRequest(reqId: String, reqType: String, accepted: Bool) {
        DispatchQueue.main.async { [self] in
            Task {
                do {
                    if reqType.lowercased() == "log" {
                        _ = try await friendRepo.updateLogRequest(logRequestId: reqId, isAccepted: accepted).get()
                    } else {
                        _ = try await friendRepo.updateFriendRequest(friendRequestId: reqId, isAccepted: accepted).get()
                    }
                    
                    // Successful
                    notificationMessage = "Successfully updated request!"
                    showingNotification = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [self] in
                        showingNotification = false
                    }
                } catch {
                    print("Error updating request: \(error.localizedDescription)")
                    
                    notificationMessage = "Error updating request"
                    showingNotification = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        self.showingNotification = false
                    }
                }
            }
        }
    }
    
    func sendFriendRequest(username: String) {
        DispatchQueue.main.async { [self] in
            Task {
                guard let userId = fb.getUserId() else {
                    return
                }
                
                do {
                    // Check if users are already friends
                    let result = try await userRepo.getUserByUsername(username: username).get()
                    
                    let userFriends = result.friends ?? [:]
                    if (userFriends.contains(where: { $0.key == userId })) {
                        notificationMessage = "You are already friends with this user!"
                        showingNotification = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            self.showingNotification = false
                        }
                        return
                    }
                    
                    // Check if target sent a request to this user
                    guard let targetId = result.userId else {
                        notificationMessage = "User not found!"
                        showingNotification = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            self.showingNotification = false
                        }
                        return
                    }
                    let targetRequests = try await userRepo.getFriendRequests(userId: targetId).get()
                    if ((targetRequests.firstIndex(where: { $0.senderId == targetId && $0.targetId == userId })) != nil) {
                        notificationMessage = "This user has already sent you a friend request!"
                        showingNotification = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            self.showingNotification = false
                        }
                        return
                    }
                    
                    // Check if user already sent a request to this target
                    let userRequests = try await userRepo.getFriendRequests(userId: userId).get()
                    if ((userRequests.firstIndex(where: { $0.senderId == userId && $0.targetId == targetId })) != nil) {
                        notificationMessage = "Friend request already sent!"
                        showingNotification = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            self.showingNotification = false
                        }
                        return
                    }
                    
                    // Try adding friend request
                    _ = try await friendRepo.addFriendRequest(senderId: userId, targetId: targetId, requestDate: String(currentTimeInMS())).get()
                    
                    // Success message
                    notificationMessage = "Successfully sent request!"
                    showingNotification = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        self.showingNotification = false
                    }
                } catch {
                    print("Error sending friend request: \(error.localizedDescription)")
                    notificationMessage = "User not found!"
                    showingNotification = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        self.showingNotification = false
                    }
                }
            }
        }
    }
    
    func updateUser(username: String, newPassword: String, password: String) {
        DispatchQueue.main.async { [self] in
            Task {
                do {
                    guard let userId = fb.getUserId() else {
                        isUnauthorized = true
                        return
                    }

                    // Check if password field is empty
                    if (!password.isEmpty) {
                        if (!username.isEmpty || !newPassword.isEmpty || avatarSelection != userData?.avatarPreset) {
                            var updates: [String: Any] = [:]
                            
                            // Add updated fields
                            if (!username.isEmpty) {
                                updates["username"] = username
                            }
                            if (!newPassword.isEmpty) {
                                updates["password"] = password
                            }
                            if (avatarSelection != userData?.avatarPreset) {
                                updates["avatar_preset"] = avatarSelection
                            }
                            
                            // Call update user
                            _ = try await userRepo.updateUser(userId: userId, password: password, updateData: updates).get()
                            
                            // Successful, update userData
                            userData = try await userRepo.getUser(userId: userId).get()
                            
                            //saveMessage = "Successfully updated settings!"
                            //messageColor = Color.green
                        } else {
                            // No changes were made
                            //saveMessage = "Please make changes before saving."
                            //messageColor = Color.red
                        }
                    } else {
                        // Password field is empty
                        //saveMessage = "Please enter your current password."
                        //messageColor = Color.red
                    }
                } catch {
                    //saveMessage = "Error, please try again later."
                    //messageColor = Color.red
                }
            }
        }
    }
    
    func logout() {
        DispatchQueue.main.async { [self] in
            Task {
                do {
                    guard let _ = fb.getUserId() else {
                        isUnauthorized = true
                        return
                    }

                    _ = try fb.logout().get()
                    
                    // Logout successful
                    isUnauthorized = false
                } catch {
                    //saveMessage = "Error, please try logging out later."
                    //messageColor = Color.red
                }
            }
        }
    }
    
    func getUserId() -> String {
        return fb.getUserId() ?? ""
    }
}
