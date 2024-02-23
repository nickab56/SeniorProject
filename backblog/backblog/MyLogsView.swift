import SwiftUI
import CoreData

struct MyLogsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var draggedLog: LogType?
    @State private var showingAddLogSheet = false
    @ObservedObject var vm: LogsViewModel

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("My Logs")
                    .font(.system(size: 24))
                    .bold()
                    .foregroundColor(.white)

                Spacer()

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
            .padding([.top, .leading, .trailing])

            ScrollView {
                switch (vm.logs.first) {
                case .log(_):
                    FirebaseLogs()
                default:
                    LocalLogs()
                }
            }
        }
        .sheet(isPresented: $showingAddLogSheet) {
            AddLogSheetView(isPresented: $showingAddLogSheet, logsViewModel: vm)
        }
    }
    
    private func LocalLogs() -> some View {
        let logList: [LocalLogData] = vm.logs.compactMap { logType in logType.toLocalLog() }
        return LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            Group {
                ForEach(logList.sorted(by: { $0.orderIndex < $1.orderIndex }), id: \.self) { log in
                    NavigationLink(destination: LogDetailsView(log: LogType.localLog(log))) {
                        LogItemView(log: LogType.localLog(log))
                            .cornerRadius(15)
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

    private func FirebaseLogs() -> some View {
        let logList: [LogData] = vm.logs.compactMap { logType in logType.toLog() }
        return LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            Group {
                ForEach(logList, id: \.self) { log in
                    NavigationLink(destination: LogDetailsView(log: LogType.log(log))) {
                        LogItemView(log: LogType.log(log))
                            .cornerRadius(15)
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
    }


    struct DropViewDelegate: DropDelegate {
        var logsViewModel: LogsViewModel
        let droppedLog: LogType
        @Binding var logs: [LogType]
        @Binding var draggedLog: LogType?
        let viewContext: NSManagedObjectContext

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
