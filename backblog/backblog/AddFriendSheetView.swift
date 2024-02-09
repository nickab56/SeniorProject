//
//  AddFriendSheetView.swift
//  backblog
//
//  Created by Jake Buhite on 2/9/24.
//

import SwiftUI
import CoreData

struct AddFriendSheetView: View {
    @Binding var isPresented: Bool
    @Binding var notificationMsg: String
    @Binding var notificationActive: Bool
    
    @State private var username = ""

    var body: some View {
        NavigationView {
            Form {
                TextField("Username", text: $username)
                    .accessibility(identifier: "usernameTextField")
                    .textInputAutocapitalization(.never)
                
                Button(action: {
                    sendFriendRequest(username: username)
                    isPresented = false
                }) {
                    Text("Send Friend Request")
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                }
                .accessibility(identifier: "sendFriendRequest")
                
                Button(action: {
                    isPresented = false
                }) {
                    Text("Cancel")
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.red)
                }
                .accessibility(identifier: "cancelSendFriendRequest")
            }
            .navigationBarTitle("Add Friend", displayMode: .inline)
        }
        .preferredColorScheme(.dark)
    }

    private func sendFriendRequest(username: String) {
        DispatchQueue.main.async {
            Task {
                guard let userId = FirebaseService.shared.auth.currentUser?.uid else {
                    return
                }
                
                do {
                    // Check if users are already friends
                    let result = try await UserRepository.getUserByUsername(username: username).get()
                    
                    let userFriends = result.friends ?? [:]
                    if (userFriends.contains(where: { $0.key == userId })) {
                        withAnimation {
                            notificationMsg = "You are already friends with this user!"
                            notificationActive = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                notificationActive = false
                            }
                        }
                        return
                    }
                    
                    // Check if target sent a request to this user
                    guard let targetId = result.userId else {
                        withAnimation {
                            notificationMsg = "User not found!"
                            notificationActive = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                notificationActive = false
                            }
                        }
                        return
                    }
                    let targetRequests = try await UserRepository.getFriendRequests(userId: targetId).get()
                    if ((targetRequests.firstIndex(where: { $0.senderId == targetId && $0.targetId == userId })) != nil) {
                        withAnimation {
                            notificationMsg = "This user has already sent you a friend request!"
                            notificationActive = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                notificationActive = false
                            }
                        }
                        return
                    }
                    
                    // Check if user already sent a request to this target
                    let userRequests = try await UserRepository.getFriendRequests(userId: userId).get()
                    if ((userRequests.firstIndex(where: { $0.senderId == userId && $0.targetId == targetId })) != nil) {
                        withAnimation {
                            notificationMsg = "Friend request already sent!"
                            notificationActive = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                notificationActive = false
                            }
                        }
                        return
                    }
                    
                    // Try adding friend request
                    _ = try await FriendRepository.addFriendRequest(senderId: userId, targetId: targetId, requestDate: String(currentTimeInMS())).get()
                    
                    // Success message
                    withAnimation {
                        notificationMsg = "Successfully sent request!"
                        notificationActive = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            notificationActive = false
                        }
                    }
                } catch {
                    print("Error sending friend request: \(error.localizedDescription)")
                    withAnimation {
                        notificationMsg = "User not found!"
                        notificationActive = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            notificationActive = false
                        }
                    }
                }
            }
        }
    }
}

