import SwiftUI

// MARK: - Parent Dashboard

struct ParentDashboardView: View {
    @EnvironmentObject var store: HousePointStore

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    KidsSectionView()
                    ChoresSectionView()
                    RewardsSectionView()
                    PendingRewardsSectionView()
                }
                .padding()
            }
            .background(
                LinearGradient(
                    colors: [Color.purple.opacity(0.4), Color.blue.opacity(0.3)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            )
            .navigationTitle("Parent Dashboard")
        }
    }
}

// MARK: - Kids Section with Add Kid Button

struct KidsSectionView: View {
    @EnvironmentObject var store: HousePointStore

    @State private var showAddKidAlert = false
    @State private var newKidName = ""

    var body: some View {
        SectionView(title: "🧒 Kids Dashboard") {
            VStack(spacing: 8) {
                // List of kids
                ForEach(store.childrenInFamily) { kid in
                    KidRow(kid: kid)
                }

                // Add Kid Button
                Button(action: {
                    showAddKidAlert = true
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Add Kid")
                    }
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green.opacity(0.7))
                    .cornerRadius(12)
                }
                .alert("Add New Kid", isPresented: $showAddKidAlert, actions: {
                    TextField("Kid's name", text: $newKidName)
                    Button("Add", action: addKid)
                    Button("Cancel", role: .cancel) {}
                }, message: {
                    Text("Enter the name of the new child.")
                })
            }
        }
    }

    // MARK: - Add Kid Action
    private func addKid() {
        let success = store.addChild(username: newKidName)
        if !success {
            // Optional: show error alert if name is empty or duplicate
            print("Failed to add kid. Name might be empty or already exists.")
        }
        newKidName = ""
    }
}

// MARK: - Kid Row

struct KidRow: View {
    @EnvironmentObject var store: HousePointStore
    var kid: User

    var body: some View {
        NavigationLink(value: kid.id) {
            HStack {
                Text(kid.username)
                    .bold()
                    .foregroundColor(.white)
                Spacer()
                Text("⭐ \(kid.points)  ⏳ \(kid.pendingPoints)")
                    .font(.subheadline)
                    .foregroundColor(.yellow)
            }
            .padding()
            .background(Color.blue.opacity(0.7))
            .cornerRadius(12)
        }
        .navigationDestination(for: UUID.self) { id in
            ChildApprovalView(childId: id).environmentObject(store)
        }
    }
}

// MARK: - Chores Section

struct ChoresSectionView: View {
    @EnvironmentObject var store: HousePointStore

    var body: some View {
        SectionView(title: "🧹 Chores") {
            NavigationLink("Chore List", destination: ChoreListView().environmentObject(store))
                .buttonStyle(ColoredButtonStyle(color: .purple))
            NavigationLink("Add New Chore", destination: AddChoreView().environmentObject(store))
                .buttonStyle(ColoredButtonStyle(color: .purple.opacity(0.7)))
        }
    }
}

// MARK: - Rewards Section

struct RewardsSectionView: View {
    @EnvironmentObject var store: HousePointStore

    var body: some View {
        SectionView(title: "🎁 Rewards") {
            NavigationLink("Reward List", destination: RewardListView().environmentObject(store))
                .buttonStyle(ColoredButtonStyle(color: .orange))
            NavigationLink("Add New Reward", destination: AddRewardView().environmentObject(store))
                .buttonStyle(ColoredButtonStyle(color: .orange.opacity(0.7)))
        }
    }
}

// MARK: - Pending Reward Requests Section

struct PendingRewardsSectionView: View {
    @EnvironmentObject var store: HousePointStore

    var body: some View {
        SectionView(title: "⏳ Pending Reward Requests") {
            ForEach(store.pendingRewardRequests.filter { request in
                guard let kid = store.users.first(where: { $0.id == request.userId }) else { return false }
                return kid.familyId == store.currentFamilyId
            }) { request in
                PendingRewardRow(request: request)
            }
        }
    }
}

struct PendingRewardRow: View {
    @EnvironmentObject var store: HousePointStore
    var request: PendingReward

    var body: some View {
        if let kid = store.users.first(where: { $0.id == request.userId }) {
            VStack(alignment: .leading, spacing: 6) {
                Text("\(kid.username) requested: \(request.reward.name)")
                    .bold()
                    .foregroundColor(.white)
                Text("Cost: \(request.reward.cost) points")
                    .font(.footnote)
                    .foregroundColor(.white.opacity(0.8))
                HStack {
                    Button("Approve") {
                        store.approveReward(request)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
                    .disabled(kid.points < store.minimumPointsToRedeem)

                    Button("Deny") {
                        store.denyReward(request)
                    }
                    .buttonStyle(.bordered)
                    .tint(.red)
                }
            }
            .padding()
            .background(Color.gray.opacity(0.7))
            .cornerRadius(12)
        }
    }
}

// MARK: - Reusable Section & Button

struct SectionView<Content: View>: View {
    let title: String
    let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .padding(.horizontal)
                .padding(.top, 8)
                .foregroundColor(.white)
            content
        }
        .padding()
        .background(Color.black.opacity(0.3))
        .cornerRadius(16)
        .shadow(radius: 5)
    }
}

struct ColoredButtonStyle: ButtonStyle {
    var color: Color
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(color)
            .cornerRadius(12)
            .shadow(radius: 3)
    }
}
