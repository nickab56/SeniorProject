//
//  FriendsProfileViewModel.swift
//  backblog
//
//  Created by Jake Buhite on 2/8/24.
//

import SwiftUI

class FriendsProfileViewModel: ObservableObject {
    @Published var friendId: String
    @Published var logs: [LogData] = []
    @Published var userData: UserData?
    @Published var friends: [UserData] = []
    
    private var fb: FirebaseProtocol
    private var userRepo: UserRepository
    private var friendRepo: FriendRepository
    private var logRepo: LogRepository
    
    @Published var showingNotification = false
    @Published var notificationMessage = ""
    
    init (friendId: String, fb: FirebaseProtocol) {
        self.fb = fb
        self.friendId = friendId
        self.userRepo = UserRepository(fb: fb)
        self.friendRepo = FriendRepository(fb: fb)
        self.logRepo = LogRepository(fb: fb)
        fetchUserData()
        fetchLogs()
        fetchFriends()
    }
    
    /**
     Fetches data for the specified friend's user profile.
     */
    private func fetchUserData() {
        DispatchQueue.main.async {
            Task {
                do {
                    let result = try await self.userRepo.getUser(userId: self.friendId).get()
                    self.userData = result
                } catch {
                    print("Error fetching user: \(error.localizedDescription)")
                }
            }
        }
    }
    
    /**
     Retrieves the public logs shared by the friend.
     */
    private func fetchLogs() {
        DispatchQueue.main.async {
            Task {
                do {
                    let result = try await self.logRepo.getLogs(userId: self.friendId, showPrivate: false).get()
                    self.logs = result
                } catch {
                    print("Error fetching logs: \(error.localizedDescription)")
                }
            }
        }
    }
    
    /**
     Fetches the list of friends for the specified user.
     */
    private func fetchFriends() {
        DispatchQueue.main.async {
            Task {
                do {
                    let result = try await self.friendRepo.getFriends(userId: self.friendId).get()
                    self.friends = result
                } catch {
                    print("Error fetching friends: \(error.localizedDescription)")
                }
            }
        }
    }
    
    
    /**
     Returns the current user's ID.

     - Returns: A string representing the user's ID.
     */
    func getUserId() -> String {
        return fb.getUserId() ?? ""
    }
    
    /**
     Removes the specified friend from the current user's friend list.
     */
    func removeFriend() {
        DispatchQueue.main.async { [self] in
            Task {
                let username = userData?.username ?? "null"
                do {
                    guard let userId = fb.getUserId() else {
                        return
                    }
                    
                    _ = try await self.friendRepo.removeFriend(userId: userId, friendId: friendId).get()
                    
                    notificationMessage = "You are no longer friends with \(username)"
                    showingNotification = true
                } catch {
                    print("Error fetching logs: \(error.localizedDescription)")
                    notificationMessage = "There was an error unfriending \(username)"
                    showingNotification = true
                }
            }
        }
    }
    
    /**
     Blocks the specified user, preventing them from interacting with the current user.
     */
    func blockUser() {
        DispatchQueue.main.async { [self] in
            Task {
                let username = userData?.username ?? "null"
                do {
                    guard let userId = fb.getUserId() else {
                        return
                    }
                    
                    _ = try await self.friendRepo.blockUser(userId: userId, blockedId: friendId).get()
                    
                    notificationMessage = "You have blocked \(username)"
                    showingNotification = true
                } catch {
                    print("Error fetching logs: \(error.localizedDescription)")
                    notificationMessage = "There was an error blocking \(username)"
                    showingNotification = true
                }
            }
        }
    }
    
    
    /**
     Checks if the specified user is already a friend of the current user.

     - Returns: A boolean indicating if the user is a friend.
     */
    func userIsFriend() -> Bool {
        return userData?.friends?.contains(where: { $0.key == getUserId() }) ?? false
    }
    
    /**
     Sends a friend request to the specified user.
     */
    func sendFriendRequest() {
        DispatchQueue.main.async { [self] in
            Task {
                guard let userId = fb.getUserId() else {
                    return
                }
                
                do {
                    // Check if users are already friends
                    let result = try await userRepo.getUser(userId: friendId).get()
                    
                    let userFriends = result.friends ?? [:]
                    if (userFriends.contains(where: { $0.key == userId })) {
                        notificationMessage = "You are already friends with this user!"
                        showingNotification = true
                        return
                    }
                    
                    // Check if target sent a request to this user
                    guard let targetId = result.userId else {
                        notificationMessage = "User not found!"
                        showingNotification = true
                        return
                    }
                    let targetRequests = try await userRepo.getFriendRequests(userId: targetId).get()
                    if ((targetRequests.firstIndex(where: { $0.senderId == userId && $0.targetId == targetId })) != nil) {
                        notificationMessage = "Friend request already sent!"
                        showingNotification = true
                        return
                    }
                    
                    // Check if user already sent a request to this target
                    let userRequests = try await userRepo.getFriendRequests(userId: userId).get()
                    if ((userRequests.firstIndex(where: { $0.senderId == targetId && $0.targetId == userId })) != nil) {
                        notificationMessage = "This user has already sent you a friend request!"
                        showingNotification = true
                        return
                    }
                    
                    // Try adding friend request
                    _ = try await friendRepo.addFriendRequest(senderId: userId, targetId: targetId, requestDate: String(currentTimeInMS())).get()
                    
                    // Success message
                    notificationMessage = "Successfully sent request!"
                    showingNotification = true
                } catch {
                    print("Error sending friend request: \(error.localizedDescription)")
                    notificationMessage = "User not found!"
                    showingNotification = true
                }
            }
        }
    }
}
