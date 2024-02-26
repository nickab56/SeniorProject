//
//  AvatarSelectionView.swift
//  backblog
//
//  Updated by Jake Buhite on 02/09/24.
//

import SwiftUI

/**
 Presents a grid of avatar options for users to select as their profile picture.

 This view displays a collection of avatars with their corresponding names. Users can tap on an avatar to select it. The selection is communicated back through a callback function provided as an `onSelect` parameter. The avatars are presented in a `LazyVGrid` layout, making this view adaptable to various screen sizes and orientations.

 - Properties:
    - `avatarNames`: An array containing the names of the avatars.
    - `avatarIds`: An array containing the image asset identifiers for the avatars.
    - `onSelect`: A closure that is called with the selected avatar's index when an avatar is tapped.

 Each avatar image is wrapped in a `VStack` with its name displayed below the image. The entire stack is tappable, and tapping an avatar invokes the `onSelect` closure with the avatar's index.
 */
struct AvatarSelectionView: View {
    let avatarNames = ["Quasar", "Cipher", "Nova", "Flux", "Torrent", "Odyssey"]
    let avatarIds = ["avatar1", "avatar2", "avatar3", "avatar4", "avatar5", "avatar6"]
    var onSelect: (Int) -> Void

    var body: some View {
        ZStack {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                ForEach(Array(zip(avatarIds.indices, avatarIds)), id: \.0) { index, avatarId in
                    VStack {
                        Image(avatarId)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .background(Color.black.opacity(0.1))
                            .cornerRadius(10)
                            .onTapGesture {
                                onSelect(index + 1)
                            }
                            .accessibility(identifier: avatarId) // Assigning accessibility identifier
                        Text(avatarNames[index])
                            .foregroundColor(.white)
                            .font(.headline)
                            .padding(.top, 5)
                    }
                    .padding()
                    .background(Color.black.opacity(0.2))
                    .cornerRadius(15)
                }
            }
        }
        .padding()
        .preferredColorScheme(.dark)
        .accessibility(identifier: "AvatarSelectionView")
    }
}
