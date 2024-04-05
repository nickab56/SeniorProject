//
//  MyLogsView.swift
//  backblog
//
//  Created by Nick Abegg on 2/18/24.
//  Updated by Jake Buhite on 2/23/23.
//
//  Description: View for displaying and managing user logs.
//

import SwiftUI
import CoreData

/**
 View for managing and displaying user logs.
 
 - Parameters:
     - draggedLog: The log type that is currently being dragged.
     - showingAddLogSheet: Boolean value indicating whether the "Add Log" sheet is shown.
     - vm: The view model for managing the logs.
 */
struct MyLogsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var draggedLog: LogType?
    @State private var showingAddLogSheet = false
    @ObservedObject var vm: LogsViewModel

    /**
     The body of `MyLogsView`, defining its layout and SwiftUI elements.
     */
    var body: some View {
        VStack(){
            HStack() {
                VStack(alignment: .leading){
                    Text("My Logs")
                        .font(.title)
                        .bold()
                        .foregroundColor(.white)
                }
                Spacer()
                VStack(alignment: .trailing){
                    Button(action: {
                        showingAddLogSheet = true
                    }) {
                        Image(systemName: "plus.square.fill.on.square.fill")
                            .foregroundColor(Color(hex: "#1b2731"))
                    }
                    .padding(8)
                    .background(Color(hex: "#3891e1"))
                    .cornerRadius(8)
                    .accessibility(identifier: "addLogButton")
                }
            }
            .padding(16)
            .sheet(isPresented: $showingAddLogSheet) {
                AddLogSheetView(isPresented: $showingAddLogSheet, logsViewModel: vm)
            }
            VStack(alignment: .leading) {
                ScrollView {
                    switch (vm.logs.first) {
                    case .log(_):
                        FirebaseLogs()
                    default:
                        LocalLogs()
                    }
                }
                Spacer()
            }
        }
    }
    
    /**
     Function to display local logs in a LazyVGrid layout.
     */
    private func LocalLogs() -> some View {
        let logList: [LocalLogData] = vm.logs.compactMap { logType in logType.toLocalLog() }
        return LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            Group {
                ForEach(logList.sorted(by: { $0.orderIndex < $1.orderIndex }), id: \.self) { log in
                    NavigationLink(destination: LogDetailsView(log: LogType.localLog(log))) {
                        LogItemView(log: LogType.localLog(log))
                            //.cornerRadius(15)
                    }
                    .overlay(
                        Rectangle()
                            .opacity(draggedLog?.toLocalLog() == log ? 0.5 : 0)
                    )
                    .onDrag {
                        self.draggedLog = LogType.localLog(log)
                        return NSItemProvider()
                    }
                    .onDrop(of: [.plainText], delegate: DropViewDelegate(logsViewModel: vm, droppedLog: LogType.localLog(log), logs: $vm.logs, draggedLog: $draggedLog, viewContext: viewContext))
                }
            }
            .animation(.easeInOut, value: logList)
        }
    }

    /**
     Function to display Firebase logs in a LazyVGrid layout.
     */
    private func FirebaseLogs() -> some View {
        let logList: [LogData] = vm.logs.compactMap { logType in logType.toLog() }
        return LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            Group {
                ForEach(logList, id: \.self) { log in
                    NavigationLink(destination: LogDetailsView(log: LogType.log(log))) {
                        LogItemView(log: LogType.log(log))
                    }
                    .overlay(
                        Rectangle()
                            .opacity(draggedLog?.toLog() == log ? 0.5 : 0)
                    )
                    .onDrag {
                        self.draggedLog = LogType.log(log)
                        return NSItemProvider()
                    }
                    .onDrop(of: [.plainText], delegate: DropViewDelegate(logsViewModel: vm, droppedLog: LogType.log(log), logs: $vm.logs, draggedLog: $draggedLog, viewContext: viewContext))
                }
            }
            .animation(.easeInOut, value: logList)
        }
        .padding(.horizontal, 16)
    }


    /**
     A drop delegate to handle drag and drop operations for logs.
     */
    struct DropViewDelegate: DropDelegate {
        var logsViewModel: LogsViewModel
        let droppedLog: LogType
        @Binding var logs: [LogType]
        @Binding var draggedLog: LogType?
        let viewContext: NSManagedObjectContext

        /**
         Function to perform the drop operation when a log is dropped.
         */
        func performDrop(info: DropInfo) -> Bool {
            guard let draggedLog = draggedLog else { return false }
            
            switch (logs.first) {
            case .log(_):
                var logList: [LogData] = logs.compactMap { logType in logType.toLog() }
                if let targetIndex = logList.firstIndex(of: droppedLog.toLog()!),
                   let sourceIndex = logList.firstIndex(of: draggedLog.toLog()!) {
                    logList.remove(at: sourceIndex)
                    logList.insert(draggedLog.toLog()!, at: targetIndex)
                    
                    // Update logs within view model
                    logs = logList.compactMap { log in LogType.log(log) }
                    
                    // Push new log order to db
                    logsViewModel.updateLogsOrder(logs: logList)
                    
                    // Update watch next
                    logsViewModel.loadNextUnwatchedMovie()
                }
            default:
                let logList: [LocalLogData] = logs.compactMap { logType in logType.toLocalLog() }
                if let targetIndex = logList.firstIndex(of: droppedLog.toLocalLog()!),
                   let sourceIndex = logList.firstIndex(of: draggedLog.toLocalLog()!) {
                    var newLogs = logList.map { $0 }
                    newLogs.remove(at: sourceIndex)
                    newLogs.insert(draggedLog.toLocalLog()!, at: targetIndex)

                    for (index, log) in newLogs.enumerated() {
                        log.orderIndex = Int32(index)
                    }
                    
                    // Update logs within view model
                    logs = newLogs.compactMap { log in LogType.localLog(log) }

                    do {
                        try viewContext.save()
                        
                        // Update watch next
                        logsViewModel.loadNextUnwatchedMovie()
                    } catch {
                        print("Failed to save context: \(error)")
                    }
                }
            }
            self.draggedLog = nil
            logsViewModel.refreshTrigger.toggle()
            return true
        }

        /**
         Function to handle the drop entered event for log dragging.
         */
        func dropEntered(info: DropInfo) {
            guard let draggedLog = draggedLog else { return }
            
            switch (draggedLog) {
            case .log(let fbLog):
                if (fbLog == droppedLog.toLog()) { return }
                let logList: [LogData] = logs.compactMap { logType in logType.toLog() }
                
                // Get from and to
                guard let from = logList.firstIndex(of: fbLog), let to = logList.firstIndex(of: droppedLog.toLog()!) else { return }

                if from < to {
                    for index in from..<to {
                        logs.swapAt(index, index + 1)
                    }
                } else {
                    for index in (to + 1)...from {
                        logs.swapAt(index, index - 1)
                    }
                }
            case .localLog(let localLog):
                if (localLog == droppedLog.toLocalLog()) { return }
                let logList: [LocalLogData] = logs.compactMap { logType in logType.toLocalLog() }
                
                guard let from = logList.firstIndex(of: draggedLog.toLocalLog()!), let to = logList.firstIndex(of: droppedLog.toLocalLog()!)
                else { return }

                if from < to {
                    for index in from..<to {
                        logs[index].toLocalLog()!.orderIndex -= 1
                    }
                } else {
                    for index in (to + 1)...from {
                        logs[index].toLocalLog()!.orderIndex += 1
                    }
                }
                draggedLog.toLocalLog()!.orderIndex = droppedLog.toLocalLog()!.orderIndex
            }
        }
    }
}
