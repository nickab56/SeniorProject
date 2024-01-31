//
//  LogItemView.swift
//  backblog
//
//  Created by Nick Abegg on 1/23/24.
//

import SwiftUI
import CoreData

// View for displaying a single log item.
struct LogItemView: View {
    let log: LocalLogData
    let maxCharacters = 20

    var body: some View {
        ZStack {
            Image("img_placeholder_log_batman")
                .resizable()
                .scaledToFill()
                .clipped()
                .overlay(Color.black.opacity(0.5))

            VStack {
                Text(truncateText(log.name ?? ""))
                    .font(.title)
                    .bold()
                    .foregroundColor(.white)
            }
        }
        .cornerRadius(15)
    }

    // Function to truncate text if it's longer than maxCharacters.
    private func truncateText(_ text: String) -> String {
        if text.count > maxCharacters {
            return String(text.prefix(maxCharacters)) + "..."
        } else {
            return text
        }
    }
}

