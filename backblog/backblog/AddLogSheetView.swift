import SwiftUI
import CoreData

// View for adding a new log entry.
struct AddLogSheetView: View {
    @Binding var isPresented: Bool
    @Environment(\.managedObjectContext) private var viewContext
    @State private var newLogName = ""

    var body: some View {
        NavigationView {
            Form {
                TextField("Log Name", text: $newLogName)
                    .accessibility(identifier: "newLogNameTextField")

                Button(action: {
                    addNewLog()
                    isPresented = false
                }) {
                    Text("Add Log")
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                }
                .accessibility(identifier: "addLogButton")
                
                Button(action: {
                    isPresented = false
                }) {
                    Text("Cancel")
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.red)
                }
                .accessibility(identifier: "cancelAddLogButton")
            }
            .navigationBarTitle("New Log", displayMode: .inline)
            
//            .navigationBarItems(trailing: Button("Cancel") {
//                isPresented = false
//            }
//            .accessibility(identifier: "cancelAddLogButton"))
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
            print("Error saving new log: \(error)")
        }
    }
}
