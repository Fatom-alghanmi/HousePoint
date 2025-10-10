import SwiftUI

struct ParentDashboardView: View {
    @EnvironmentObject var store: HousePointStore

    var body: some View {
        List {
            Section(header: Text("Kids Dashboard")) {
                ForEach(store.users.filter { !$0.isParent }) { kid in
                    NavigationLink(destination:
                        KidDashboardView(currentUserId: kid.id)
                            .environmentObject(store)
                    ) {
                        Text(kid.username)
                    }
                }

                NavigationLink("Register Child") {
                    RegisterChildView()
                        .environmentObject(store)
                }
            }

            Section(header: Text("Chores")) {
                NavigationLink("Chore List") {
                    ChoreListView()
                        .environmentObject(store)
                }

                NavigationLink("Add New Chore") {
                    AddChoreView()
                        .environmentObject(store)
                }
            }

            Section(header: Text("Rewards")) {
                NavigationLink("Reward List") {
                    RewardListView()
                        .environmentObject(store)
                }

                NavigationLink("Add New Reward") {
                    AddRewardView()
                        .environmentObject(store)
                }
            }
        }
        .navigationTitle("Parent Dashboard")
    }
}

#Preview {
    let mockStore = HousePointStore()

    let sampleParent = User(id: UUID(), username: "Parent", password: "1234", points: 0, isParent: true)
    let sampleChild = User(id: UUID(), username: "Alex", password: "", points: 0, isParent: false)
    let sampleChore = Chore(id: UUID(), title: "Take out trash", assignedTo: sampleChild.id, isCompleted: false)

    mockStore.users = [sampleParent, sampleChild]
    mockStore.chores = [sampleChore]

    return ParentDashboardView()
        .environmentObject(mockStore)
}
