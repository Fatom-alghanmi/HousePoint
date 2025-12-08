import SwiftUI

struct ChoreListView: View {
    @EnvironmentObject var store: HousePointStore

    // States for image picking
    @State private var showImagePicker = false
    @State private var selectedImage: UIImage? = nil
    @State private var currentChoreForImage: Chore? = nil

    var body: some View {
        List {
            ForEach(store.chores) { chore in
                VStack(alignment: .leading, spacing: 6) {

                    // TITLE + COMPLETION
                    HStack {
                        Text(chore.title)
                            .font(.headline)
                        Spacer()
                        Text(chore.isCompleted ? "✅" : "❌")
                    }

                    // OPTIONAL DESCRIPTION
                    if let desc = chore.description, !desc.isEmpty {
                        Text(desc)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    // OPTIONAL IMAGE
                    if let choreImage = chore.image {
                        Image(uiImage: choreImage)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 120)
                            .cornerRadius(10)
                            .shadow(radius: 4)
                    }

                    // ADD IMAGE BUTTON (Parent only)
                    if store.currentUser?.isParent == true {
                        Button("Add / Change Image") {
                            currentChoreForImage = chore
                            showImagePicker = true
                        }
                        .buttonStyle(.bordered)
                    }

                    // ASSIGNMENT PICKER (Parent only)
                    if store.currentUser?.isParent == true {
                        HStack {
                            Text("Assigned to:")
                            Picker("", selection: binding(for: chore)) {
                                Text("Unassigned").tag(UUID?.none)
                                ForEach(store.users.filter { !$0.isParent }) { user in
                                    Text(user.username).tag(Optional(user.id))
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                        }
                    }

                    // MARK COMPLETE BUTTON (Child only)
                    if let user = store.currentUser,
                       !user.isParent,
                       chore.assignedTo == user.id {
                        Button(chore.isMarkedDoneByChild ? "Marked Done ⏳" : "Mark as Done") {
                            store.markChoreDoneByChild(chore)
                        }
                        .disabled(chore.isMarkedDoneByChild || chore.isCompleted)
                        .buttonStyle(.bordered)
                    }
                }
                .padding(.vertical, 6)
            }
        }
        .navigationTitle("Chore List")
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $selectedImage)
                .onDisappear {
                    if let image = selectedImage, let chore = currentChoreForImage {
                        store.addImage(image, to: chore)
                    }
                    selectedImage = nil
                    currentChoreForImage = nil
                }
        }
    }

    // BINDING FOR ASSIGNMENT (Parent only)
    private func binding(for chore: Chore) -> Binding<UUID?> {
        guard let index = store.chores.firstIndex(where: { $0.id == chore.id }) else {
            return .constant(nil)
        }
        return Binding<UUID?>(
            get: { store.chores[index].assignedTo },
            set: { newValue in
                if let id = newValue,
                   let user = store.users.first(where: { $0.id == id }) {
                    store.assignChore(store.chores[index], to: user)
                } else {
                    store.chores[index].assignedTo = nil
                }
                store.saveData()
            }
        )
    }
}

#Preview {
    let mockStore = HousePointStore()

    // Sample users
    let parent = User(id: UUID(), username: "Parent", password: "1234", points: 0, isParent: true)
    let child1 = User(id: UUID(), username: "Alex", password: "", points: 0, isParent: false)
    let child2 = User(id: UUID(), username: "Jamie", password: "", points: 0, isParent: false)

    mockStore.users = [parent, child1, child2]

    // Sample chores
    let chore1 = Chore(id: UUID(), title: "Take out trash", description: "Put it outside before 8am", assignedTo: child1.id, isCompleted: false)
    let chore2 = Chore(id: UUID(), title: "Wash dishes", description: nil, assignedTo: nil, isCompleted: false)

    mockStore.chores = [chore1, chore2]

    return ChoreListView()
        .environmentObject(mockStore)
}
