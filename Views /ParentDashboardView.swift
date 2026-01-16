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

// MARK: - Kids Section with Add & Remove Kid
struct KidsSectionView: View {
    @EnvironmentObject var store: HousePointStore
    
    @State private var showAddKidSheet = false
    @State private var newKidName = ""
    @State private var addKidErrorMessage = ""      // dynamic error message
    @State private var kidToRemove: User?
    @State private var showRemoveAlert = false
    
    var body: some View {
        SectionView(title: "🧒 Kids Dashboard") {
            VStack(spacing: 8) {
                // List of kids
                ForEach(store.childrenInFamily) { kid in
                    KidRow(kid: kid, removeAction: {
                        kidToRemove = kid
                        showRemoveAlert = true
                    })
                }
                
                // Add Kid Button
                Button(action: {
                    newKidName = ""
                    addKidErrorMessage = ""
                    showAddKidSheet = true
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
                // MARK: - Add Kid Sheet UI
                .sheet(isPresented: $showAddKidSheet) {
                    VStack(spacing: 20) {
                        // Title
                        Text("Add New Kid")
                            .font(.title2)
                            .bold()
                            .foregroundColor(.purple)
                        
                        // TextField with nice styling
                        TextField("Kid's name", text: $newKidName)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.15), radius: 5, x: 0, y: 2)
                        
                        // Dynamic error message
                        if !addKidErrorMessage.isEmpty {
                            Text(addKidErrorMessage)
                                .foregroundColor(.red)
                                .font(.subheadline)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        
                        // Buttons
                        HStack(spacing: 15) {
                            Button(action: {
                                showAddKidSheet = false
                                newKidName = ""
                                addKidErrorMessage = ""
                            }) {
                                Text("Cancel")
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.gray)
                                    .cornerRadius(12)
                                    .shadow(radius: 3)
                            }

                            Button(action: {
                                if let error = store.addChild(username: newKidName) {
                                    addKidErrorMessage = error
                                } else {
                                    showAddKidSheet = false
                                    newKidName = ""
                                    addKidErrorMessage = ""
                                }
                            }) {
                                Text("Add")
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.green)
                                    .cornerRadius(12)
                                    .shadow(radius: 3)
                            }
                        }
                    }
                    .padding(30)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(Color(UIColor.systemGray6))
                            .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
                    )
                    .padding()
                }

            }
            // MARK: - Remove Kid Alert
            .alert("Remove Kid?", isPresented: $showRemoveAlert, actions: {
                Button("Remove", role: .destructive) {
                    if let kid = kidToRemove {
                        store.removeChild(kid)
                        kidToRemove = nil
                    }
                }
                Button("Cancel", role: .cancel) {
                    kidToRemove = nil
                }
            }, message: {
                Text("Are you sure you want to remove this child?")
            })
        }
    }
}

// MARK: - Kid Row with Remove Button
struct KidRow: View {
    @EnvironmentObject var store: HousePointStore
    var kid: User
    var removeAction: () -> Void

    var body: some View {
        HStack {
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
                ChildApprovalView(childId: id)
                    .environmentObject(store)
            }

            // Remove Button
            Button(action: removeAction) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
                    .padding(8)
            }
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
