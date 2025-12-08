//
//  ChildApprovalView.swift
//  HousePoint
//
//  Created by Fatom on 2025-12-07.
//

import SwiftUI

struct ChildApprovalView: View {
    @EnvironmentObject var store: HousePointStore
    let childId: UUID

    var body: some View {
        VStack {
            if let child = store.users.first(where: { $0.id == childId }) {
                Text("\(child.username)'s Chores")
                    .font(.title)
                    .padding()

                List {
                    ForEach(store.chores.filter { $0.assignedTo == childId }) { chore in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(chore.title)
                                    .font(.headline)
                                if chore.isMarkedDoneByChild && !chore.isCompleted {
                                    Text("⏳ Pending approval")
                                        .font(.subheadline)
                                        .foregroundColor(.orange)
                                } else if chore.isCompleted {
                                    Text("✅ Completed")
                                        .font(.subheadline)
                                        .foregroundColor(.green)
                                } else {
                                    Text("❌ Not done")
                                        .font(.subheadline)
                                        .foregroundColor(.red)
                                }
                            }
                            Spacer()

                            // Parent approve/unapprove buttons
                            if chore.isMarkedDoneByChild && !chore.isCompleted {
                                Button("Approve ✅") {
                                    store.approveChore(chore)
                                }
                                .buttonStyle(.borderedProminent)
                            } else if chore.isCompleted {
                                Button("Unapprove") {
                                    store.unapproveChore(chore)
                                }
                                .buttonStyle(.bordered)
                            }
                        }
                        .padding(.vertical, 5)
                    }
                }
                .listStyle(InsetGroupedListStyle())
            } else {
                Text("Child not found")
                    .foregroundColor(.red)
            }
        }
        .navigationTitle("Child Approval")
    }
}

