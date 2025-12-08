import SwiftUI

struct ParentDashboardView: View {
    @EnvironmentObject var store: HousePointStore

    var body: some View {
        NavigationStack {
            List {
                kidsSection
                choresSection
                rewardsSection
                pendingRewardsSection
            }
            .navigationTitle("Parent Dashboard")
        }
    }

    // MARK: - Sections

    private var kidsSection: some View {
        Section(header: Text("Kids Dashboard")) {
            ForEach(store.users.filter { !$0.isParent }) { kid in
                NavigationLink(destination: ChildApprovalView(childId: kid.id)
                                .environmentObject(store)) {
                    HStack {
                        Text(kid.username)
                        Spacer()
                        Text("⭐ \(kid.points)  ⏳ \(kid.pendingPoints)")
                            .font(.subheadline)
                            .foregroundColor(.orange)
                    }
                }
            }

            NavigationLink("Register Child") {
                RegisterChildView()
                    .environmentObject(store)
            }
        }
    }

    private var choresSection: some View {
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
    }

    private var rewardsSection: some View {
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

    private var pendingRewardsSection: some View {
        Section(header: Text("Pending Reward Requests")) {
            ForEach(store.pendingRewardRequests) { request in
                if let kid = store.users.first(where: { $0.id == request.userId }) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("\(kid.username) requested: \(request.reward.name)")
                            Text("Cost: \(request.reward.cost) points")
                                .font(.footnote)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        HStack {
                            Button("Approve") {
                                store.approveReward(request)
                            }
                            .buttonStyle(.borderedProminent)

                            Button("Deny") {
                                store.denyReward(request)
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    let mockStore = HousePointStore()

    let parent = User(id: UUID(), username: "Parent", password: "1234", points: 0, isParent: true)
    let child1 = User(id: UUID(), username: "Alex", password: "", points: 5, isParent: false)
    let child2 = User(id: UUID(), username: "Jamie", password: "", points: 10, isParent: false)

    let chore1 = Chore(id: UUID(), title: "Take out trash", assignedTo: child1.id, isCompleted: true)
    let chore2 = Chore(id: UUID(), title: "Wash dishes", assignedTo: child2.id, isCompleted: false)

    let reward1 = Reward(id: UUID(), name: "Ice Cream", cost: 10)
    let pendingReward = PendingReward(id: UUID(), userId: child1.id, reward: reward1)

    mockStore.users = [parent, child1, child2]
    mockStore.chores = [chore1, chore2]
    mockStore.rewards = [reward1]
    mockStore.pendingRewardRequests = [pendingReward]

    return ParentDashboardView()
        .environmentObject(mockStore)
}
