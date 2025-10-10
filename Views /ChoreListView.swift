import SwiftUI

struct ChoreListView: View {
    @EnvironmentObject var store: HousePointStore

    var body: some View {
        List {
            ForEach(store.chores) { chore in
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(chore.title)
                            .font(.headline)
                        Spacer()
                        if chore.isCompleted {
                            Text("✅")
                        } else {
                            Text("❌")
                        }
                    }

                    HStack {
                        Text("Assigned to:")
                        Picker("", selection: binding(for: chore)) {
                            Text("Unassigned").tag(UUID?.none)
                            ForEach(store.users.filter { !$0.isParent }) { user in
                                Text(user.username).tag(Optional(user.id))
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .navigationTitle("Chore List")
    }

    private func binding(for chore: Chore) -> Binding<UUID?> {
        Binding<UUID?>(
            get: {
                chore.assignedTo
            },
            set: { newValue in
                if let id = newValue,
                   let user = store.users.first(where: { $0.id == id }) {
                    store.assignChore(chore, to: user)
                } else {
                    store.unassignChore(chore)
                }
                store.saveData()
            }
        )
    }
}

#Preview {
    let mockStore = HousePointStore()

    // Sample users
    let parent = User(id: UUID(), username: "Parent", password: "1234", points: 0, isParent: true)
    let child1 = User(id: UUID(), username: "Alex", password: "", points: 0, isParent: false)
    let child2 = User(id: UUID(), username: "Jamie", password: "", points: 0, isParent: false)

    mockStore.users = [parent, child1, child2]

    // Sample chores
    let chore1 = Chore(id: UUID(), title: "Take out trash", assignedTo: child1.id, isCompleted: false)
    let chore2 = Chore(id: UUID(), title: "Wash dishes", assignedTo: nil, isCompleted: false)

    mockStore.chores = [chore1, chore2]

    return ChoreListView()
        .environmentObject(mockStore)
}
