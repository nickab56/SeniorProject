//
//  SocialViewModel.swift
//  backblog
//
//  Created by Jake Buhite on 2/12/24.
//

import CoreData
import Firebase

/**
 Manages social features within the app, handling user data, friend and log requests, and notifications.

 - `logs`: Stores logs for the social view.
 - `selectedTab`: Tracks the currently selected tab in the social view.
 - `userData`: Holds information about the currently logged-in user.
 - `friends`: A list of the user's friends.
 - `friendRequests`: A list of incoming friend requests and the users who sent them.
 - `logRequests`: A list of log sharing requests from other users.
 - `showingNotification`: Controls the visibility of notifications.
 - `notificationMessage`: The message to display in a notification.
 - `showingSendFriendReqSheet`: Determines whether the send friend request sheet is displayed.
 - `isUnauthorized`: Indicates whether the user is unauthorized.
 - `avatarSelection`: Stores the user's avatar selection.

 The class provides functions to fetch user data, logs, friends, friend requests, and log requests. It also includes functions for updating and sending friend requests, updating user settings, logging out, syncing local logs to the database, and resetting all local logs.
*/
class SocialViewModel: ObservableObject {
    @Published var logs: [LogData] = []
    @Published var selectedTab = "Logs"
    @Published var userData: UserData?
    @Published var friends: [UserData] = []
    @Published var friendRequests: [(FriendRequestData, UserData)] = []
    @Published var logRequests: [(LogRequestData, UserData)] = []
    @Published var blockedUsers: [UserData] = []
    
    // Notification message
    @Published var showingNotification = false
    @Published var notificationMessage = ""
    @Published var showingSendFriendReqSheet = false
    
    // Settings
    @Published var isUnauthorized = false
    @Published var avatarSelection = 1
    
    // Listeners
    private var friendListener: ListenerRegistration?
    private var logReqListener: ListenerRegistration?
    private var friendReqListener: ListenerRegistration?
   
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
        initFriendListeners()
    }
    
    deinit {
        removeListeners()
    }
   
    /**
     Fetches and updates the current user's data from the database.
     */
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
   
    /**
     Updates the status of a request (accept or reject) based on the given parameters.
     
     - Parameters:
       - reqId: The ID of the request to update.
       - reqType: The type of the request (e.g., "friend" or "log").
       - accepted: A boolean indicating whether the request was accepted or rejected.
     */
    func updateRequest(reqId: String, reqType: String, accepted: Bool) {
        DispatchQueue.main.async { [self] in
            Task {
                do {
                    if reqType.lowercased() == "log" {
                        _ = try await friendRepo.updateLogRequest(logRequestId: reqId, isAccepted: accepted).get()
                        self.fetchLogRequests()
                    } else {
                        _ = try await friendRepo.updateFriendRequest(friendRequestId: reqId, isAccepted: accepted).get()
                        self.fetchFriendRequests()
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
    
    /**
     Sends a friend request to the user with the specified username.

     - Parameters:
       - username: The username of the user to whom the friend request will be sent.
     */
    func sendFriendRequest(username: String) {
        DispatchQueue.main.async { [self] in
            Task {
                guard let userId = fb.getUserId() else {
                    return
                }
                
                do {
                    // Get user data
                    let result = try await userRepo.getUserByUsername(username: username).get()
                    
                    // Check if users are already friends
                    let userFriends = result.friends ?? [:]
                    if (userFriends.contains(where: { $0.key == userId })) {
                        notificationMessage = "You are already friends with this user!"
                        showingNotification = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            self.showingNotification = false
                        }
                        return
                    }
                    
                    // Check if valid userId. Also check if user has been blocked
                    guard let targetId = result.userId, userData?.blocked?[targetId] == nil, result.blocked?[userId] == nil else {
                        notificationMessage = "User not found!"
                        showingNotification = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            self.showingNotification = false
                        }
                        return
                    }
                    
                    // Check if target sent a request to this user
                    let targetRequests = try await userRepo.getFriendRequests(userId: targetId).get()
                    if ((targetRequests.firstIndex(where: { $0.senderId == userId && $0.targetId == targetId })) != nil) {
                        notificationMessage = "Friend request already sent!"
                        showingNotification = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            self.showingNotification = false
                        }
                        return
                    }
                    
                    // Check if user already sent a request to this target
                    let userRequests = try await userRepo.getFriendRequests(userId: userId).get()
                    if ((userRequests.firstIndex(where: { $0.senderId == targetId && $0.targetId == userId })) != nil) {
                        notificationMessage = "This user has already sent you a friend request!"
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
    
    /**
     Updates the current user's profile information, including username and password.

     - Parameters:
       - username: The new username for the user.
       - newPassword: The new password for the user.
       - password: The current password of the user for verification.
     */
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
                        if (!username.isEmpty || !newPassword.isEmpty || avatarSelection != (userData?.avatarPreset ?? 1)) {
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
                            
                            notificationMessage = "Successfully updated settings!"
                            showingNotification = true
                        } else {
                            // No changes were made
                            notificationMessage = "Please make changes before saving."
                            showingNotification = true
                        }
                    } else {
                        // Password field is empty
                        notificationMessage = "Please enter your current password."
                        showingNotification = true
                    }
                } catch {
                    notificationMessage = "Error, please try again later."
                    showingNotification = true
                }
            }
        }
    }
    
    
    /**
     Logs out the current user from the application.
     */
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
                    isUnauthorized = true
                } catch {
                    notificationMessage = "Error, please try logging out later."
                    showingNotification = true
                }
            }
        }
    }
    
    func getUserId() -> String {
        return fb.getUserId() ?? ""
    }
    
    /**
     Counts the number of local logs stored in CoreData.

     - Returns: The count of local logs.
     */
    func getLocalLogCount() -> Int {
        let context = PersistenceController.shared.container.viewContext

        let fetchRequest: NSFetchRequest<LocalLogData> = LocalLogData.fetchRequest()
        do {
            let items = try context.fetch(fetchRequest)
            return items.count
        } catch let error as NSError {
            print("Error resetting logs: \(error), \(error.userInfo)")
        }
        return 0
    }
    
    private func initFriendListeners() {
        guard let userId = fb.getUserId() else {
            return
        }
        
        // Log Requests
        logReqListener = fb.getCollectionRef(refName: "log_requests")?
            .whereField("target_id", isEqualTo: userId).whereField("is_complete", isEqualTo: false)
            .addSnapshotListener { querySnapshot, error in
                guard let snapshot = querySnapshot else {
                    print("Error fetching snapshots: \(error!)")
                    return
                }
                
                snapshot.documentChanges.forEach { diff in
                    // New or modified log requests
                    if (diff.type == .added || diff.type == .modified || diff.type == .removed) {
                        self.fetchLogRequests()
                    }
                }
            }
        
        // Friend Requests (Fetch both friends and friend requests)
        friendReqListener = fb.getCollectionRef(refName: "friend_requests")?
            .whereField("target_id", isEqualTo: userId).whereField("is_complete", isEqualTo: false)
            .addSnapshotListener { querySnapshot, error in
                guard let snapshot = querySnapshot else {
                    print("Error fetching snapshots: \(error!)")
                    return
                }
                
                snapshot.documentChanges.forEach { diff in
                    if (diff.type == .added || diff.type == .modified || diff.type == .removed) {
                        self.fetchFriendRequests()
                    }
                }
            }
        
        // Friends
        // Optimizations could be made to improve the performance of this listener
        friendListener = fb.getCollectionRef(refName: "users")?.document(userId)
            .addSnapshotListener { documentSnapshot, error in
                guard documentSnapshot != nil else {
                    print("Error fetching document: \(error!)")
                    return
                }
                
                self.fetchUserData()
                self.fetchFriends()
            }
    }
    
    private func removeListeners() {
        logReqListener?.remove()
        friendReqListener?.remove()
        friendListener?.remove()
    }
    
    func fetchBlockedUsers() {
        DispatchQueue.main.async { [self] in
            Task {
                guard let userId = fb.getUserId() else {
                    print("User ID not found")
                    return
                }
                
                do {
                    let userData = try await userRepo.getUser(userId: userId).get()
                    guard let blockedIds = userData.blocked?.keys else {
                        print("No blocked users found")
                        return
                    }
                    
                    var blockedUsersData: [UserData] = []
                    for blockedId in blockedIds {
                        do {
                            let blockedUserData = try await userRepo.getUser(userId: blockedId).get()
                            blockedUsersData.append(blockedUserData)
                        } catch {
                            print("Failed to fetch blocked user data for ID: \(blockedId)")
                        }
                    }
                    
                    DispatchQueue.main.async {
                        self.blockedUsers = blockedUsersData
                    }
                } catch {
                    print("Error fetching user data: \(error)")
                }
            }
        }
    }
    
    func unblockUser(userId: String, blockedId: String) async {
        do {
            // Remove blockedId from the current user's blocked list
            let update = ["blocked.\(blockedId)": FieldValue.delete()]
            _ = try await fb.put(updates: update, docId: userId, collection: "users").get()
            
            fetchBlockedUsers()
            
            print("User \(blockedId) successfully unblocked.")
        } catch {
            print("Failed to unblock user \(blockedId): \(error)")
        }
    }


}
