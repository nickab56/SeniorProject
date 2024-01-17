//
//  BackBlogiOS2App.swift
//  BackBlogiOS2
//
//  Created by Nick Abegg on 1/16/24.
//

import SwiftUI

@main
struct BackBlogiOS2App: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
