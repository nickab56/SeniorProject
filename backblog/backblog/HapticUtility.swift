//
//  HapticUtility.swift
//  backblog
//
//  Created by Nick Abegg on 4/7/24.
//

import UIKit

class HapticFeedbackManager {
    static let shared = HapticFeedbackManager()

    private init() {}

    func triggerSelectionFeedback() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }

    func triggerImpactFeedback(style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }

    func triggerNotificationFeedback(type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }
}
