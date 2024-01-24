//
//  LogDetailsView.swift
//  backblog
//
//  Created by Nick Abegg on 1/23/24.
//

import SwiftUI
import CoreData

// View for displaying the details of a log.
struct LogDetailView: View {
    let log: LogEntity
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack {
            Text("Details for Log \(log.logname ?? "Unknown")")
                .accessibility(identifier: "logDetailsText")

            // Button to delete the log entry.
            Button("Delete Log") {
                deleteLog()
            }
            .foregroundColor(.red)
            .accessibility(identifier: "deleteLogButton")
        }
    }

    // Function to handle the deletion of a log.
    private func deleteLog() {
        viewContext.delete(log)

        do {
            try viewContext.save()
            presentationMode.wrappedValue.dismiss()
        } catch {
            // Error handling for failed deletion.
            print("Error deleting log: \(error)")
        }
    }
}
