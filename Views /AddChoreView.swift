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
                ForEach(store.childrenInFamily) { child in
                    Text(child.username).tag(Optional(child.id))
                }
            }
            .pickerStyle(.menu)
            .padding()

            Button("Add Chore") {
                guard !title.trimmingCharacters(in: .whitespaces).isEmpty,
                      let familyId = store.currentFamilyId else { return }

                let newChore = Chore(
                    id: UUID(),
                    title: title,
                    assignedTo: assignedUserId,
                    isCompleted: false,
                    isMarkedDoneByChild: false,
                    imageData: nil,
                    familyId: familyId
                )

                store.chores.append(newChore)
                store.saveData()

                title = ""
                assignedUserId = nil
            }
            .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
            .buttonStyle(.borderedProminent)
            .padding()
        }
        .padding()
    }
}
