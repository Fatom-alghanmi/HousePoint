import SwiftUI

struct KidDashboardView: View {
    @EnvironmentObject var store: HousePointStore
    let currentUserId: UUID
    
    @State private var showAlert = false
    @State private var alertText = ""

    var body: some View {
        VStack(alignment: .leading) {
            if let user = store.users.first(where: { $0.id == currentUserId }) {
                
                Text("Hi \(user.username)!").font(.largeTitle).bold()
                Text("⭐ Stars: \(user.points)").font(.title2).foregroundColor(.orange)
                
                List {
                    Section("Assigned Chores") {
                        ForEach(store.chores.filter { $0.assignedTo == currentUserId && !$0.isCompleted }) { chore in
                            ChoreRow(chore: chore)
                        }
                    }
                    
                    Section("Pending Approval") {
                        ForEach(store.chores.filter { $0.assignedTo == currentUserId && $0.isMarkedDoneByChild }) { chore in
                            Text("\(chore.title) (Pending)")
                        }
                    }
                    
                    Section("Approved Chores") {
                        ForEach(store.chores.filter { $0.assignedTo == currentUserId && $0.isCompleted }) { chore in
                            Text(chore.title).strikethrough()
                        }
                    }
                }
                
                Button("Redeem Reward (25 points)") {
                    if user.points < 10 {
                        alertText = "Not enough points!"
                    } else {
                        if let reward = store.rewards.first {
                            store.requestReward(reward, by: user)
                            alertText = "Reward request sent to parent!"
                        } else {
                            alertText = "No rewards available!"
                        }
                    }
                    showAlert = true
                }
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(8)
                
            }
        }
        .alert(alertText, isPresented: $showAlert) { Button("OK", role: .cancel) {} }
        .navigationTitle("Kid Dashboard")
    }
}
