//
//  ContentView.swift
//  backblog
//
//  Created by Nick Abegg on 12/18/23.
//
//  Description:
//  ContentView serves as the primary view of the BackBlog app. It sets up the main tab
//  navigation interface and manages the display of different content sections including
//  logs, search, and social functionalities.

import SwiftUI
import CoreData

struct ContentView: View {
    // Access the managed object context for Core Data operations.
    @Environment(\.managedObjectContext) private var viewContext

    // FetchRequest to retrieve LogEntity objects sorted by 'logid'.
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \LogEntity.logid, ascending: true)],
        animation: .default)
    private var logs: FetchedResults<LogEntity>

    // Initializer to configure navigation and tab bar appearances.
    init() {
        NavConfigUtility.configureNavigationBar()
        NavConfigUtility.configureTabBar()
    }

    // The main body of ContentView.
    var body: some View {
        GeometryReader { geometry in
            // Tab view serving as the main navigation component.
            TabView {
                // Main content view with log entries.
                NavigationView {
                    mainContentView(geometry: geometry)
                }
                .tabItem {
                    Image(systemName: "square.stack.3d.up")
                }

                // Search functionality.
                NavigationView {
                    SearchView()
                        .navigationTitle("Search")
                }
                .tabItem {
                    Image(systemName: "magnifyingglass")
                }

                // Social interaction view.
                NavigationView {
                    SocialView()
                        .navigationTitle("Social")
                }
                .tabItem {
                    Image(systemName: "person.2.fill")
                }
            }
            .accentColor(.white)
        }
        .onAppear {
            // Configure the tab bar's appearance on view appearance.
            UITabBar.appearance().barTintColor = .white
        }
    }

    // Helper function to create the main content view.
    private func mainContentView(geometry: GeometryProxy) -> some View {
        ScrollView {
            VStack {
                // Custom title for the main content area.
                CustomTitleView(title: "What's Next?")
                    .bold()
                    .padding(.top, geometry.size.height * 0.08)

                // Display the first log entry if available.
                if let firstLog = logs.first {
                    LogDisplayView(log: firstLog, geometry: geometry)
                }

                // View for managing and displaying user logs.
                MyLogsView()
                    .padding(.bottom, 150)
            }
        }
        // Background styling for the main content area.
        .background(LinearGradient(gradient: Gradient(colors: [Color(hex: "#3b424a"), Color(hex: "#212222")]), startPoint: .topLeading, endPoint: .bottomTrailing))
        .edgesIgnoringSafeArea(.all)
    }
}

// View for displaying a single log entry.
private struct LogDisplayView: View {
    let log: LogEntity
    let geometry: GeometryProxy

    var body: some View {
        VStack(alignment: .leading) {
            Text("From \(log.logname ?? "Unknown")")
                .font(.subheadline)
                .foregroundColor(.white)
                .padding(.leading)

            // Placeholder image for the log.
            Image("img_placeholder_poster")
                .resizable()
                .scaledToFit()
                .frame(width: geometry.size.width * 0.9)
        }
    }
}

// Preview provider for ContentView.
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        // Inject the managed object context for preview purposes.
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
