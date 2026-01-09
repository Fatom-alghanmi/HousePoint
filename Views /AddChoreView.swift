import SwiftUI

struct AddChoreView: View {
    @EnvironmentObject var store: HousePointStore
    @State private var title = ""
    @State private var assignedUserId: UUID?

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)],
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Text("Add New Chore")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.white)
                    .padding(.top)

                VStack(spacing: 16) {
                    TextField("Chore title", text: $title)
                        .padding()
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(10)
                        .shadow(radius: 3)

                    Picker("Assign to:", selection: $assignedUserId) {
                        Text("Unassigned").tag(UUID?.none)
                        ForEach(store.childrenInFamily) { child in
                            Text(child.username).tag(Optional(child.id))
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .padding()
                    .background(Color.white.opacity(0.9))
                    .cornerRadius(10)
                    .shadow(radius: 3)

                    Button(action: addChore) {
                        Text("Add Chore")
                            .bold()
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.green)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                    }
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
                .padding()
                .background(Color.black.opacity(0.3))
                .cornerRadius(20)
                .shadow(radius: 10)

                Spacer()
            }
            .padding()
        }
    }

    private func addChore() {
        guard !title.trimmingCharacters(in: .whitespaces).isEmpty,
              let familyId = store.currentFamilyId else { return }

        let newChore = Chore(
            id: UUID(),
            title: title,
            assignedTo: assignedUserId,
            isCompleted: false,
            isMarkedDoneByChild: false,
            imageData: nil,
            familyId: familyId
        )

        store.chores.append(newChore)
        store.saveData()
        title = ""
        assignedUserId = nil
    }
}
