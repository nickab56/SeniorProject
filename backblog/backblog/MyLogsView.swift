//
//  MyLogsView.swift
//  backblog
//
//  Created by Nick Abegg on 12/23/23.
//
//  Description:
//  MyLogsView displays a list of log entries in the BackBlog app. It includes functionality
//  for adding new logs and viewing detailed information about each log.

import SwiftUI
import CoreData

// The view for displaying and managing user logs.
struct MyLogsView: View {
    @Environment(\.managedObjectContext) private var viewContext

    // Fetch request to retrieve and sort log entries.
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \LogEntity.logid, ascending: true)],
        animation: .default)
    private var logs: FetchedResults<LogEntity>

    // State variable to control the presentation of the add log sheet.
    @State private var showingAddLogSheet = false

    var body: some View {
        VStack(alignment: .leading) {
            // Header section with title and add button.
            HStack {
                Text("My Logs")
                    .font(.system(size: 24))
                    .bold()
                    .foregroundColor(.white)

                Spacer()

                // Button to show the add log sheet.
                Button(action: {
                    showingAddLogSheet = true
                }) {
                    Image(systemName: "plus.square.fill.on.square.fill")
                        .foregroundColor(Color(hex: "#1b2731"))
                }
                .padding(8)
                .background(Color(hex: "#3891e1"))
                .cornerRadius(8)
            }
            .padding([.top, .leading, .trailing])

            // Scrollable grid view of log entries.
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                    ForEach(logs, id: \.self) { log in
                        NavigationLink(destination: LogDetailView(log: log)) {
                            LogItemView(log: log)
                        }
                        .padding(10)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        // Presentation of the add log sheet.
        .sheet(isPresented: $showingAddLogSheet) {
            AddLogSheetView(isPresented: $showingAddLogSheet)
        }
    }
}

// View for adding a new log entry.
struct AddLogSheetView: View {
    @Binding var isPresented: Bool
    @Environment(\.managedObjectContext) private var viewContext
    @State private var newLogName = ""

    var body: some View {
        NavigationView {
            Form {
                TextField("Log Name", text: $newLogName)
                Button("Add Log") {
                    addNewLog()
                    isPresented = false
                }
            }
            .navigationBarTitle("Add New Log", displayMode: .inline)
            .navigationBarItems(trailing: Button("Cancel") {
                isPresented = false
            })
        }
    }

    // Function to handle the creation of a new log.
    private func addNewLog() {
        let newLog = LogEntity(context: viewContext)
        newLog.logname = newLogName
        newLog.logid = Int64(UUID().hashValue)

        do {
            try viewContext.save()
        } catch {
            // Error handling for failed save.
        }
    }
}

// View for displaying a single log item.
struct LogItemView: View {
    let log: LogEntity

    var body: some View {
        ZStack {
            // Placeholder image for the log.
            Image("img_placeholder_log_batman")
                .resizable()
                .scaledToFill()
                .frame(width: 150, height: 150)
                .clipped()
                .cornerRadius(5)

            // Text overlay with log information.
            VStack {
                Text(log.logname ?? "")
                    .font(.title)
                    .bold()
                    .foregroundColor(.white)
            }
            .frame(width: 150, height: 150)
            .background(Color.black.opacity(0.7))
            .cornerRadius(5)
        }
    }
}

// View for displaying the details of a log.
struct LogDetailView: View {
    let log: LogEntity
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack {
            Text("Details for Log \(log.logname ?? "Unknown")")

            // Button to delete the log entry.
            Button("Delete Log") {
                deleteLog()
            }
            .foregroundColor(.red)
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
        }
    }
}
