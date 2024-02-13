//
//  AddFriendSheetView.swift
//  backblog
//
//  Created by Jake Buhite on 2/9/24.
//

import SwiftUI
import CoreData

struct AddFriendSheetView: View {
    @ObservedObject var viewModel: SocialViewModel
    
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
                    viewModel.sendFriendRequest(username: username)
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
}

