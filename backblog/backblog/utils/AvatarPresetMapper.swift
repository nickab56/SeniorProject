//
//  AvatarPresetMapper.swift
//  backblog
//
//  Created by Jake Buhite on 1/31/24.
//

import Foundation

func getAvatarId(avatarPreset: Int) -> String {
    switch avatarPreset {
    case 1:
        return "avatar1" //("Quasar", "avatar1")
    case 2:
        return "avatar2" //("Cipher", "avatar2")
    case 3:
        return "avatar3" //("Nova", "avatar3")
    case 4:
        return "avatar4" //("Flux", "avatar4")
    case 5:
        return "avatar5" //("Torrent", "avatar5")
    case 6:
        return "avatar6" //("Odyssey", "avatar6")
    default:
        return "avatar1" // ("Quasar", "avatar1")
    }
}
