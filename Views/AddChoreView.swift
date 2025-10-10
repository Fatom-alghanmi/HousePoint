import SwiftUI

struct AddChoreView: View {
    @EnvironmentObject var store: HousePointStore
    @State private var title = ""
    @State private var assignedUserId: UUID?

    var body: some View {
        VStack {
            Text("Add New Chore")
                .font(.title)
                .padding()
            
            TextField("Chore title", text: $title)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Picker("Assign to:", selection: $assignedUserId) {
                Text("Unassigned").tag(UUID?.none)
                ForEach(store.users) { user in
                    if !user.isParent {
                        Text(user.username).tag(Optional(user.id))
                    }
                }
            }
            .pickerStyle(MenuPickerStyle())
            .padding()
            
            Button("Add Chore") {
                let newChore = Chore(id: UUID(), title: title, assignedTo: assignedUserId, isCompleted: false)
                store.chores.append(newChore)
                title = ""
                assignedUserId = nil
            }
            .buttonStyle(.borderedProminent)
            .padding()
        }
        .padding()
    }
}
