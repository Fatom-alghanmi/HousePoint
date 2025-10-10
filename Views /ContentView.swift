import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: HousePointStore
    @State private var showParentWelcome = true
    @State private var navigationPath = NavigationPath() // ✅ Track nav path

    var body: some View {
        NavigationStack(path: $navigationPath) {
            if store.currentUser == nil {
                LoginView()
            } else if let user = store.currentUser {
                if user.isParent {
                    if showParentWelcome {
                        ParentWelcomeView(showParentWelcome: $showParentWelcome)
                            .environmentObject(store)
                            .onAppear {
                                navigationPath.removeLast(navigationPath.count) // ✅ Reset toolbar/nav bar
                            }
                    } else {
                        ParentDashboardWrapper(showParentWelcome: $showParentWelcome)
                            .environmentObject(store)
                    }
                } else {
                    KidDashboardView(currentUserId: user.id)
                        .environmentObject(store)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                LogoutButton()
                            }
                        }
                }
            }
        }
        .accentColor(.purple)
    }
}

struct ParentDashboardWrapper: View {
    @EnvironmentObject var store: HousePointStore
    @Binding var showParentWelcome: Bool

    var body: some View {
        ParentDashboardView()
            .environmentObject(store)
            .toolbar {
                // ✅ Only here: back to Welcome
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        withAnimation {
                            showParentWelcome = true
                        }
                    }) {
                        Label("Back", systemImage: "arrow.backward")
                            .foregroundColor(.blue)
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    LogoutButton()
                }
            }
    }
}

struct ParentWelcomeView: View {
    @Binding var showParentWelcome: Bool
    @EnvironmentObject var store: HousePointStore

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            Image("Chore")
                .resizable()
                .scaledToFit()
                .frame(width: 180, height: 180)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .shadow(radius: 8)

            Text("Use the menu to manage kids, chores, and rewards.")
                .font(.title3)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Spacer()

            Button("Enter Dashboard") {
                withAnimation {
                    showParentWelcome = false
                }
            }
            .buttonStyle(.borderedProminent)
            .padding(.bottom, 40)
        }
        .navigationTitle("Welcome to HousePoint!")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                LogoutButton()
            }
        }
        .padding()
    }
}

struct LogoutButton: View {
    @EnvironmentObject var store: HousePointStore

    var body: some View {
        Button(action: {
            store.logout()
        }) {
            Label("Logout", systemImage: "arrow.turn.up.left.circle")
                .foregroundColor(.red)
        }
    }
}

#Preview {
    let store = HousePointStore()
    return ContentView()
        .environmentObject(store)
}
