//
//  AddFriendSheetView.swift
//  backblog
//
//  Created by Jake Buhite on 2/9/24.
//

import SwiftUI
import CoreData

/**
 Displays a sheet for sending a friend request by entering a username.

 This view includes a text field for the user to input the username of the friend they wish to add. It provides a button to send the friend request, which triggers the `sendFriendRequest` function in the `SocialViewModel` with the entered username. There's also a cancel button to dismiss the sheet without sending a request.

 - Parameters:
    - viewModel: The `SocialViewModel` used for sending the friend request.
    - isPresented: A binding to control the sheet's presentation state.
    - notificationMsg: A binding to the message displayed in a notification.
    - notificationActive: A binding to control the visibility of notifications.
*/
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
                    .accessibility(identifier: "addUsernameTextField")
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

