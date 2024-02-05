import SwiftUI
import CoreData

struct MyLogsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var draggedLog: LocalLogData?
    @State private var showingAddLogSheet = false
    @ObservedObject var logsViewModel: LogsViewModel

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \LocalLogData.log_id, ascending: true)],
        animation: .default)
    private var logs: FetchedResults<LocalLogData>

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
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ForEach(logs.sorted(by: { $0.orderIndex < $1.orderIndex }), id: \.self) { log in
                        Group {
                            NavigationLink(destination: LogDetailsView(log: log)) {
                                LogItemView(log: LogType.localLog(log))
                                    .cornerRadius(15)
                            }
                            .overlay(
                                Rectangle()
                                .opacity(draggedLog == log ? 0.5 : 0)
                            )
                            .onDrag {
                                self.draggedLog = log
                                return NSItemProvider()
                            }
                            .onDrop(of: [.plainText], delegate: DropViewDelegate(logsViewModel: logsViewModel, droppedLog: log, logs: logs, draggedLog: $draggedLog, viewContext: viewContext))
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddLogSheet) {
            AddLogSheetView(isPresented: $showingAddLogSheet)
        }
    }

    struct DropViewDelegate: DropDelegate {
        var logsViewModel: LogsViewModel
        let droppedLog: LocalLogData
        let logs: FetchedResults<LocalLogData>
        @Binding var draggedLog: LocalLogData?
        let viewContext: NSManagedObjectContext

        func performDrop(info: DropInfo) -> Bool {
            guard let draggedLog = draggedLog else { return false }

            if let targetIndex = logs.firstIndex(of: droppedLog),
               let sourceIndex = logs.firstIndex(of: draggedLog) {
                var newLogs = logs.map { $0 }
                newLogs.remove(at: sourceIndex)
                newLogs.insert(draggedLog, at: targetIndex)

                for (index, log) in newLogs.enumerated() {
                    log.orderIndex = Int32(index)
                }

                do {
                    try viewContext.save()
                } catch {
                    print("Failed to save context: \(error)")
                }
            }

            self.draggedLog = nil
            
            logsViewModel.refreshTrigger.toggle()
            
            return true
        }

        func dropEntered(info: DropInfo) {
            guard let draggedLog = draggedLog,
                  draggedLog != droppedLog,
                  let from = logs.firstIndex(of: draggedLog),
                  let to = logs.firstIndex(of: droppedLog)
            else { return }

            if from < to {
                for index in from..<to {
                    logs[index].orderIndex -= 1
                }
            } else {
                for index in (to + 1)...from {
                    logs[index].orderIndex += 1
                }
            }
            draggedLog.orderIndex = droppedLog.orderIndex
        }
    }
}
