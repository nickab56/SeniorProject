//
//  SocialView.swift
//  backblog
//
//  Created by Nick Abegg on 12/23/23.
//
//  Description:
//  SocialView serves as the social interaction hub within the BackBlog app.
//  It features a user profile section, a tab view for Logs and Friends, and
//  a grid display of the user's logs.

import SwiftUI
import CoreData

struct SocialView: View {
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \LogEntity.logid, ascending: true)],
        animation: .default)
    private var logs: FetchedResults<LogEntity>

    @State private var selectedTab = "Logs"

    var body: some View {
        VStack {
            // Spacer to push content down
            Spacer(minLength: 20) // Adjust the space as needed

            // Profile section
            HStack(alignment: .center) {
                Image(systemName: "person.crop.circle") // Using system symbol for profile picture
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60) // Size of the profile picture
                    .padding(.leading)

                Text("Username") // Placeholder for user's name
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.leading)

                Spacer()
            }
            .padding(.top, 50) // Additional padding at the top of the profile section

            // Tab View for Logs and Friends
            Picker("Options", selection: $selectedTab) {
                Text("Logs").tag("Logs")
                Text("Friends").tag("Friends")
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()

            // Grid display based on selected tab
            if selectedTab == "Logs" {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                        ForEach(logs, id: \.self) { log in
                            LogItemView(log: log)
                        }
                    }
                    .padding(.horizontal)
                }
            } else {
                Text("Friends View") // Placeholder for friends view
            }
        }
        .background(LinearGradient(gradient: Gradient(colors: [Color(hex: "#3b424a"), Color(hex: "#212222")]), startPoint: .topLeading, endPoint: .bottomTrailing))
        .edgesIgnoringSafeArea(.all)
    }
}
