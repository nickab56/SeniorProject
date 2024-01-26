import SwiftUI
import CoreData

struct MyLogsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var draggedLog: LogEntity?
    @State private var selectedLogForDetails: LogEntity?
    @State private var showingAddLogSheet = false

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \LogEntity.logid, ascending: true)],
        animation: .default)
    private var logs: FetchedResults<LogEntity>

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
                            LogItemView(log: log)
                                .cornerRadius(15)
                                .overlay(
                                    Rectangle()
                                    .opacity(draggedLog == log ? 0.5 : 0)
                                )
                                .onDrag {
                                    self.draggedLog = log
                                    return NSItemProvider()
                                }
                                .onDrop(of: [.plainText], delegate: DropViewDelegate(droppedLog: log, logs: logs, draggedLog: $draggedLog, viewContext: viewContext))
                                .simultaneousGesture(TapGesture().onEnded {
                                    self.selectedLogForDetails = log
                                })
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddLogSheet) {
            AddLogSheetView(isPresented: $showingAddLogSheet)
        }
        .sheet(item: $selectedLogForDetails) { log in
            LogDetailsView(log: log)
        }
    }
    
    struct DropViewDelegate: DropDelegate {
        let droppedLog: LogEntity
        let logs: FetchedResults<LogEntity>
        @Binding var draggedLog: LogEntity?
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
