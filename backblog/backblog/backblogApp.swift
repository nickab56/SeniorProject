//
//  backblogApp.swift
//  backblog
//
//  Created by Nick Abegg on 12/18/23.
//
//  Description: Entry point to the app. Setsup firebase config and roots to landing page.
//  Establishes persistence



import SwiftUI

@main
struct backblogApp: App {
    let persistenceController = PersistenceController.shared

    @State private var showingSplash = true

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
        }
    }
}

