//
//  ChoreCard.swift
//  HousePoint
//

import SwiftUI

struct ChoreCard: View {
    @EnvironmentObject var store: HousePointStore
    var chore: Chore

    var body: some View {
        HStack(spacing: 12) {

            // MARK: - Chore Image
            if let image = chore.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .shadow(radius: 2)
            }

            // MARK: - Title & Description
            VStack(alignment: .leading, spacing: 4) {
                Text(chore.title)
                    .font(.headline)
                    .foregroundColor(.white)

                if let desc = chore.description, !desc.isEmpty {
                    Text(desc)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                        .lineLimit(2)
                }
            }

            Spacer()

            // MARK: - Child Controls
            if let user = store.currentUser,
               !user.isParent,
               chore.assignedTo == user.id {

                if chore.isCompleted {

                    // Approved by parent
                    Text("Approved ✅")
                        .foregroundColor(.green)
                        .font(.caption)
                        .padding(6)
                        .background(Color.black.opacity(0.3))
                        .cornerRadius(8)

                } else {

                    // Mark Done / Undo (SAME button, toggles)
                    Button(chore.isMarkedDoneByChild ? "Undo" : "Mark Done") {
                        store.toggleChoreDoneByChild(chore)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(chore.isMarkedDoneByChild ? .orange : .green)
                }
            }
        }
        .padding()
        .background(Color.blue.opacity(0.7))
        .cornerRadius(12)
        .shadow(radius: 3)
    }
}
