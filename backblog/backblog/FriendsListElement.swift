//
//  FriendsListElement.swift
//  backblog
//
//  Created by Jake Buhite on 2/8/24.
//

import SwiftUI

struct FriendListElement: View {
    let friendId: String
    let userId: String
    let username: String
    let avatarPreset: Int
        
    var body: some View {
        if friendId != userId {
            NavigationLink(destination: FriendsProfileView(friendId: friendId)) {
                HStack {
                    let preset = getAvatarId(avatarPreset: avatarPreset)
                    Image(uiImage: UIImage(named: preset) ?? UIImage())
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                                                            
                    Text(username)
                        .font(.headline)
                        .foregroundColor(.white)
                                
                    Spacer()
                }.cornerRadius(10)
            }
        } else {
            NavigationLink(destination: SocialView()) {
                HStack {
                    let preset = getAvatarId(avatarPreset: avatarPreset)
                    Image(uiImage: UIImage(named: preset) ?? UIImage())
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                                                            
                    Text(username)
                        .font(.headline)
                        .foregroundColor(.white)
                                
                    Spacer()
                }.cornerRadius(10)
            }
        }
    }
}
