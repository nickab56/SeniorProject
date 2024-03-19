//
//  backblogApp.swift
//  backblog
//
//  Created by Nick Abegg on 12/18/23.
//  Updated by Jake Buhite on 02/23/24.
//
//  Description: Entry point to the app. Sets Up firebase config and roots to landing page.
//  Establishes persistence
//

import SwiftUI
import CoreData
import Firebase

/**
 Main struct for the app. Initializes the app, sets up Firebase, establishes persistence, and defines the AppDelegate.
 */
@main
struct backblogApp: App {
    /**
     Instance of PersistenceController that manages the CoreData stack and provides context of modifying the data
     */
    let persistenceController = PersistenceController.shared

    /**
     Manages the visibility of the splash screen on launch
     */
    @State private var showingSplash = true
    
    /**
     Uses the AppDelegate to handle UIApplicationDelegate functions (i.e., when configuring Firebase).
     */
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    /**
     Defines the AppDelegate class, the class currently responsible for initializing Firebase.
     */
    class AppDelegate: NSObject, UIApplicationDelegate {
        /**
         The method called when the app finishes launching.
         */
        func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
            FirebaseApp.configure()
            return true
        }
    }

    /**
     Defines the main view for the app.
     */
    var body: some Scene {
        WindowGroup {
            Group {
                if showingSplash {
                    SplashScreenView()
                } else {
                    LandingView()
                        .environment(\.managedObjectContext, persistenceController.container.viewContext)
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    withAnimation(.easeOut(duration: 2.0)) {
                        showingSplash = false
                    }
                }
            }
            .onAppear
            {
                if CommandLine.arguments.contains("--uitesting-reset") {
                    // Call method to delete all logs
                    resetAllLogs()
                }
            }
        }
    }
    
    /**
     Deletes all logs (array of LocalLogData) stored in Core Data. Fetches all logs, deletes each one, and saves changes to CoreData.
     */
    func resetAllLogs() {
        let context = PersistenceController.shared.container.viewContext

        let fetchRequest: NSFetchRequest<LocalLogData> = LocalLogData.fetchRequest()
        do {
            let items = try context.fetch(fetchRequest)
            for item in items {
                context.delete(item)
            }
            try context.save()
        } catch let error as NSError {
            print("Error resetting logs: \(error), \(error.userInfo)")
        }
    }


}

