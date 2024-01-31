//
//  backblogApp.swift
//  backblog
//
//  Created by Nick Abegg on 12/18/23.
//
//  Description: Entry point to the app. Setsup firebase config and roots to landing page.
//  Establishes persistence



import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        return true
    }
}

// The main structure for the BackBlog application.
@main
struct backblogApp: App {
    // Shared instance of the PersistenceController.
    // This handles all the Core Data stack setup and management.
    let persistenceController = PersistenceController.shared
    
    // allows for use in preview content view. comment out persistence from above
    //let persistenceController = PersistenceController.preview

    // The body of the App protocol. Defines the content of the application's scenes.
    var body: some Scene {
        WindowGroup {
            // The root view of the app is LandingView.
            LandingView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

