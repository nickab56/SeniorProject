//
//  AvatarSelectionView.swift
//  backblog
//
//  Updated by Jake Buhite on 02/09/24.
//

import SwiftUI

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
        .preferredColorScheme(.dark) // Force dark mode
        .accessibility(identifier: "AvatarSelectionView")
    }
}
