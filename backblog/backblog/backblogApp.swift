//
//  backblogApp.swift
//  backblog
//
//  Created by Nick Abegg on 12/18/23.
//

import SwiftUI

@main
struct backblogApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
