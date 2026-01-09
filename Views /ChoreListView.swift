import SwiftUI

// MARK: - Chore List View
struct ChoreListView: View {
    @EnvironmentObject var store: HousePointStore

    @State private var showImagePicker = false
    @State private var selectedImage: UIImage? = nil
    @State private var currentChoreForImage: Chore? = nil

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(store.choresInFamily) { chore in
                    VStack(spacing: 0) {
                        // Chore row for display
                        ChoreRow(chore: chore)
                            .environmentObject(store)

                        // Parent controls
                        if store.currentUser?.isParent == true {
                            VStack(spacing: 8) {
                                Button("Add / Change Image") {
                                    currentChoreForImage = chore
                                    showImagePicker = true
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(.blue)

                                HStack {
                                    Text("Assigned to:")
                                        .foregroundColor(.white)
                                    Picker("", selection: bindingForChore(chore)) {
                                        Text("Unassigned")
                                            .foregroundColor(.white)
                                            .tag(UUID?.none)
                                        ForEach(store.childrenInFamily) { child in
                                            Text(child.username)
                                                .foregroundColor(.white)
                                                .tag(Optional(child.id))
                                        }
                                    }
                                    .pickerStyle(MenuPickerStyle())
                                    .accentColor(.black)
                                }

                            }
                            .padding(.horizontal)
                            .padding(.bottom, 8)
                        }
                    }
                    .background(Color.blue.opacity(0.7))
                    .cornerRadius(12)
                    .shadow(radius: 3)
                }
            }
            .padding()
        }
        .navigationTitle("Chore List")
        .background(
            LinearGradient(
                colors: [Color.white.opacity(0.3), Color.blue.opacity(0.2)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        )
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

    // MARK: - Parent Picker Binding
    private func bindingForChore(_ chore: Chore) -> Binding<UUID?> {
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
                    store.saveData()
                }
            }
        )
    }
}
