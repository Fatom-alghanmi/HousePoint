import SwiftUI

struct ParentLoginView: View {
    @EnvironmentObject var store: HousePointStore

    @State private var username = ""
    @State private var password = ""
    @State private var errorMessage = ""
    @State private var navigateToDashboard = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("Parent Login")
                    .font(.largeTitle)

                TextField("Username", text: $username)
                    .textFieldStyle(.roundedBorder)

                SecureField("Password", text: $password)
                    .textFieldStyle(.roundedBorder)

                Button("Login") {
                    let success = store.login(
                        username: username,
                        password: password
                    )

                    if success {
                        errorMessage = ""
                        navigateToDashboard = true
                    } else {
                        errorMessage = "Invalid username or password"
                    }
                }
                .buttonStyle(.borderedProminent)

                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                }

                NavigationLink(
                    destination: ParentDashboardView()
                        .environmentObject(store),
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
    ParentLoginView()
        .environmentObject(HousePointStore())
}
