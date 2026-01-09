import SwiftUI

struct ChildApprovalView: View {
    @EnvironmentObject var store: HousePointStore
    let childId: UUID

    // Precompute chores for this child
    var childChores: [Chore] {
        store.chores.filter { $0.assignedTo == childId }
    }

    var body: some View {
        VStack {
            if let child = store.users.first(where: { $0.id == childId }) {
                Text("\(child.username)'s Chores")
                    .font(.title)
                    .padding()

                List(childChores) { chore in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(chore.title)
                                .font(.headline)
                            Text(choreStatus(chore))
                                .font(.subheadline)
                                .foregroundColor(statusColor(chore))
                        }

                        Spacer()

                        // Only show Approve button if needed
                        if chore.isMarkedDoneByChild && !chore.isCompleted {
                            Button("Approve ✅") {
                                store.approveChore(chore)
                            }
                            .buttonStyle(.borderedProminent)
                        }

                        // We do NOT call unapproveChore because it doesn't exist
                    }
                    .padding(.vertical, 5)
                }
                .listStyle(InsetGroupedListStyle())

            } else {
                Text("Child not found")
                    .foregroundColor(.red)
            }
        }
        .navigationTitle("Child Approval")
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
