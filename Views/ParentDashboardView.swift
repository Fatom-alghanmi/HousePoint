import SwiftUI

struct ParentDashboardView: View {
    @EnvironmentObject var store: HousePointStore
    @State private var showingAddChore = false

    var body: some View {
        VStack {
            Text("Parent Dashboard")
                .font(.largeTitle)
                .padding()
            
            Button("Add New Chore") {
                showingAddChore = true
            }
            .buttonStyle(.borderedProminent)
            .padding()

            List {
                ForEach(store.chores) { chore in
                    HStack {
                        Text(chore.title)
                        Spacer()
                        if let assignedTo = chore.assignedTo,
                           let user = store.users.first(where: { $0.id == assignedTo }) {
                            Text("Assigned to: \(user.username)")
                        } else {
                            Text("Unassigned")
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddChore) {
            AddChoreView()
                .environmentObject(store)
        }
    }
}
