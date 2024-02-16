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
    
    func getUserId() -> String {
        return fb.getUserId() ?? ""
    }
}
