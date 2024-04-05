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

@main
struct backblogApp: App {
    let persistenceController = PersistenceController.shared
    @State private var showingSplash = true
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    class AppDelegate: NSObject, UIApplicationDelegate {
        func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
            FirebaseApp.configure()
            
            return true
        }
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if showingSplash {
                    SplashScreenView()
                        .onAppear {
                            // Perform logout if "--uitesting-reset" is present in arguments
                            if CommandLine.arguments.contains("--uitesting-reset") {
                                // Asynchronously sign out the user and reset all logs
                                Task {
                                    await signOutUserForUITesting()
                                    resetAllLogs()
                                }
                            }
                            // Your existing splash screen logic here...
                        }
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
        }
    }
    
    /*
     TO DO: Have resetAllLogs also include online logs so that the test starts fresh no matter what
     Additoinally, have it sign the user out if possibl
     */
    
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
    
    func signOutUserForUITesting() async {
        let firebaseService = FirebaseService() // Assuming you have access to FirebaseService here
        _ = await firebaseService.logout()
    }


}

