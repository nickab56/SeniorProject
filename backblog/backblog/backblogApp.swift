//
//  backblogApp.swift
//  backblog
//
//  Created by Nick Abegg on 12/18/23.
//
//  Description:
//  The entry point for the BackBlog app, a collaborative movie playlist application.
//  This file sets up the main window of the application and provides the necessary
//  environment for managing Core Data.

import SwiftUI

// The main structure for the BackBlog application.
@main
struct backblogApp: App {
    // Shared instance of the PersistenceController.
    // This handles all the Core Data stack setup and management.
    let persistenceController = PersistenceController.shared

    // The body of the App protocol. Defines the content of the application's scenes.
    var body: some Scene {
        WindowGroup {
            // The root view of the app is ContentView.
            // The managed object context from the PersistenceController is injected
            // into the ContentView's environment, allowing Core Data to be used within
            // the application's views.
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

