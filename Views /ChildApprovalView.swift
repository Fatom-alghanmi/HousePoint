import SwiftUI

struct ChildApprovalView: View {
    @EnvironmentObject var store: HousePointStore
    let childId: UUID

    // Precompute chores for this child
    var childChores: [Chore] {
        store.chores.filter { $0.assignedTo == childId }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if let child = store.users.first(where: { $0.id == childId }) {
                    // Child Header
                    VStack {
                        Text(child.username)
                            .font(.largeTitle)
                            .bold()
                            .foregroundColor(.white)
                        Text("⭐ Points: \(child.points)  ⏳ Pending: \(child.pendingPoints)")
                            .foregroundColor(.yellow)
                            .font(.headline)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        LinearGradient(
                            colors: [Color.purple, Color.blue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(16)
                    .shadow(radius: 5)

                    // Chores Section
                    VStack(alignment: .leading, spacing: 15) {
                        ForEach(childChores) { chore in
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(chore.title)
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    Text(choreStatus(chore))
                                        .font(.subheadline)
                                        .foregroundColor(statusColor(chore))
                                }

                                Spacer()

                                // Approve button if pending
                                if chore.isMarkedDoneByChild && !chore.isCompleted {
                                    Button("Approve ✅") {
                                        store.approveChore(chore)
                                    }
                                    .buttonStyle(.borderedProminent)
                                    .tint(.green)
                                }
                            }
                            .padding()
                            .background(
                                LinearGradient(
                                    colors: [Color.gray.opacity(0.7), Color.black.opacity(0.5)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .cornerRadius(12)
                            .shadow(radius: 3)
                        }

                        if childChores.isEmpty {
                            Text("No chores assigned yet.")
                                .foregroundColor(.white.opacity(0.7))
                                .italic()
                                .padding(.top, 10)
                        }
                    }
                    .padding(.horizontal)
                } else {
                    Text("Child not found")
                        .foregroundColor(.red)
                        .font(.title2)
                        .bold()
                }
            }
            .padding(.vertical)
        }
        .background(
            LinearGradient(
                colors: [Color.black.opacity(0.9), Color.blue.opacity(0.4)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
        .navigationTitle("Child Approval")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Helpers
    private func choreStatus(_ chore: Chore) -> String {
        if chore.isMarkedDoneByChild && !chore.isCompleted {
            return "⏳ Pending approval"
        } else if chore.isCompleted {
            return "✅ Completed"
        } else {
            return "❌ Not done"
        }
    }

    private func statusColor(_ chore: Chore) -> Color {
        if chore.isMarkedDoneByChild && !chore.isCompleted {
            return .orange
        } else if chore.isCompleted {
            return .green
        } else {
            return .red
        }
    }
}
