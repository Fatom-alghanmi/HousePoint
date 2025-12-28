import SwiftUI

struct KidLoginView: View {
    @EnvironmentObject var store: HousePointStore

    @State private var selectedChildId: UUID? = nil
    @State private var navigateToDashboard = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Kid Login")
                    .font(.largeTitle)
                    .bold()

                Picker("Select Child", selection: $selectedChildId) {
                    Text("Select").tag(UUID?.none)

                    ForEach(store.users.filter { !$0.isParent }) { user in
                        Text(user.username)
                            .tag(Optional(user.id))
                    }
                }
                .pickerStyle(MenuPickerStyle())

                Button("Login") {
                    if let id = selectedChildId {
                        store.currentUserId = id
                        navigateToDashboard = true
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(selectedChildId == nil)

                // ✅ NavigationLink triggers dashboard when login is successful
                NavigationLink(
                    destination: selectedChildId != nil
                        ? KidDashboardView(currentUserId: selectedChildId!)
                            .environmentObject(store)
                        : nil,
                    isActive: $navigateToDashboard
                ) {
                    EmptyView()
                }
            }
            .padding()
        }
    }
}

#Preview {
    let store = HousePointStore()
    return KidLoginView()
        .environmentObject(store)
}
