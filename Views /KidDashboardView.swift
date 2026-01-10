//
//  KidDashboardView.swift
//  HousePoint
//
//  Updated by Fatom
//

import SwiftUI

struct KidDashboardView: View {
    @EnvironmentObject var store: HousePointStore
    let currentUserId: UUID

    @State private var showAlert = false
    @State private var alertText = ""

    var user: User? {
        store.users.first { $0.id == currentUserId }
    }

    var assignedChores: [Chore] {
        store.chores.filter { $0.assignedTo == currentUserId && !$0.isCompleted }
    }

    var pendingChores: [Chore] {
        store.chores.filter { $0.assignedTo == currentUserId && $0.isMarkedDoneByChild }
    }

    var approvedChores: [Chore] {
        store.chores.filter { $0.assignedTo == currentUserId && $0.isCompleted }
    }

    var body: some View {
        ZStack {
            LinearGradient(colors: [.purple.opacity(0.6), .blue.opacity(0.5), .pink.opacity(0.4)],
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    if let user = user {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Hi \(user.username)! 🎉")
                                .font(.largeTitle)
                                .bold()
                                .foregroundColor(.white)
                            Text("⭐ Stars: \(user.points)")
                                .font(.title2)
                                .foregroundColor(.yellow)
                        }
                        .padding()
                        .background(Color.black.opacity(0.3))
                        .cornerRadius(12)

                        // Assigned Chores
                        if !assignedChores.isEmpty {
                            Text("🧹 Assigned Chores")
                                .font(.headline)
                                .foregroundColor(.white)
                            ForEach(assignedChores) { chore in
                                ChoreCard(chore: chore)
                            }
                        }

                        // Pending Chores
                        if !pendingChores.isEmpty {
                            Text("⏳ Pending Approval")
                                .font(.headline)
                                .foregroundColor(.white)
                            ForEach(pendingChores) { chore in
                                ChoreCard(chore: chore)
                            }
                        }

                        // Approved Chores
                        if !approvedChores.isEmpty {
                            Text("✅ Approved Chores")
                                .font(.headline)
                                .foregroundColor(.white)
                            ForEach(approvedChores) { chore in
                                ChoreCard(chore: chore)
                            }
                        }

                        // Redeem Reward
                        Button(action: redeemReward) {
                            Text("Redeem Reward (\(store.minimumPointsToRedeem) points)")
                                .bold()
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(LinearGradient(colors: [.yellow, .orange], startPoint: .leading, endPoint: .trailing))
                                .foregroundColor(.white)
                                .cornerRadius(12)
                                .shadow(radius: 5)
                        }
                        .padding(.horizontal)
                    }
                }
                .padding()
            }
        }
        .alert(alertText, isPresented: $showAlert) { Button("OK", role: .cancel) {} }
        .navigationTitle("Kid Dashboard")
    }

    private func redeemReward() {
        guard let user = user else { return }

        if user.points < store.minimumPointsToRedeem {
            alertText = "Not enough points!"
        } else if let reward = store.rewards.first {
            store.requestReward(reward, by: user)
            alertText = "Reward request sent to parent!"
        } else {
            alertText = "No rewards available!"
        }
        showAlert = true
    }
}
