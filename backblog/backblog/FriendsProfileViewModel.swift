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
    
    init (friendId: String) {
        self.friendId = friendId
        fetchUserData()
        fetchLogs()
        fetchFriends()
    }
    
    private func fetchUserData() {
        DispatchQueue.main.async {
            Task {
                do {
                    let result = try await UserRepository.getUser(userId: self.friendId).get()
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
                    let result = try await LogRepository.getLogs(userId: self.friendId, showPrivate: false).get()
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
                    let result = try await FriendRepository.getFriends(userId: self.friendId).get()
                    self.friends = result
                } catch {
                    print("Error fetching friends: \(error.localizedDescription)")
                }
            }
        }
    }
}
