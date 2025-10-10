import SwiftUI

struct KidDashboardView: View {
    @EnvironmentObject var store: HousePointStore
    let currentUserId: UUID

    @State private var showRedeemAlert = false
    @State private var redeemSuccess = false
    @State private var redeemMessage = ""

    var body: some View {
        VStack(alignment: .leading) {
            if let user = store.users.first(where: { $0.id == currentUserId }) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Hi \(user.username)!")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.purple)

                    Text("⭐ Stars: \(user.points)")
                        .font(.title2)
                        .foregroundColor(.orange)

                    // Redeem points button
                    Button(action: {
                        redeemPoints(for: user)
                    }) {
                        Text("Redeem Points")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(user.points >= 10 ? Color.green : Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .disabled(user.points < 10)
                    .padding(.vertical, 5)
                }
                .padding()

                List {
                    Section(header: Text("Assigned Chores").font(.headline).foregroundColor(.blue)) {
                        ForEach(store.chores.filter { $0.assignedTo == currentUserId && !$0.isCompleted }) { chore in
                            ChoreRow(chore: chore)
                                .environmentObject(store)
                        }
                    }

                    Section(header: Text("Completed Chores").font(.headline).foregroundColor(.green)) {
                        ForEach(store.chores.filter { $0.assignedTo == currentUserId && $0.isCompleted }) { chore in
                            HStack {
                                Text(chore.title)
                                    .strikethrough()
                                Spacer()
                                Button(action: {
                                    store.unapproveChore(chore)
                                }) {
                                    Label("Undo", systemImage: "arrow.uturn.backward.circle.fill")
                                        .foregroundColor(.orange)
                                }
                            }
                            .padding(.vertical, 5)
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
            } else {
                Text("Child not found")
                    .foregroundColor(.red)
            }
        }
        .navigationTitle("Kid Dashboard")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    store.logout()
                }) {
                    Label("Logout", systemImage: "arrowshape.turn.up.left.fill")
                        .foregroundColor(.red)
                }
            }
        }
        .alert(isPresented: $showRedeemAlert) {
            Alert(
                title: Text(redeemSuccess ? "Success" : "Error"),
                message: Text(redeemMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }

    private func redeemPoints(for user: User) {
        let requiredPoints = 10

        if user.points >= requiredPoints {
            if let index = store.users.firstIndex(where: { $0.id == user.id }) {
                store.users[index].points -= requiredPoints
                redeemSuccess = true
                redeemMessage = "🎉 You redeemed \(requiredPoints) points!"
            }
        } else {
            redeemSuccess = false
            redeemMessage = "You need at least \(requiredPoints) points to redeem."
        }

        showRedeemAlert = true
    }
}

#Preview {
    let mockStore = HousePointStore()

    let child = User(id: UUID(), username: "Alex", password: "", points: 10, isParent: false)
    let chore1 = Chore(id: UUID(), title: "Take out trash", assignedTo: child.id, isCompleted: false)
    let chore2 = Chore(id: UUID(), title: "Wash dishes", assignedTo: child.id, isCompleted: true)

    mockStore.users = [child]
    mockStore.chores = [chore1, chore2]

    return KidDashboardView(currentUserId: child.id)
        .environmentObject(mockStore)
}
