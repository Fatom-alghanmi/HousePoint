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
            ForEach(store.childrenInFamily) { kid in
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
            // ✅ Register Child link removed
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
            ForEach(store.pendingRewardRequests.filter { request in
                guard let kid = store.users.first(where: { $0.id == request.userId }) else { return false }
                return kid.familyId == store.currentFamilyId
            }) { request in
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
