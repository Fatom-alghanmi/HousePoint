import SwiftUI

struct LoginView: View {
    @EnvironmentObject var store: HousePointStore
    @State private var username = ""
    @State private var password = ""
    @State private var loginSuccess = false
    @State private var showingRegister = false
    @State private var showError = false
    @State private var isParentLogin = false // starts OFF

    var body: some View {
        VStack(spacing: 20) {
            Text("Welcome to HousePoint")
                .font(.largeTitle)

            Toggle("Parent Login", isOn: $isParentLogin)
                .padding()

            TextField("Username", text: $username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            if isParentLogin {
                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
            }

            if showError {
                Text("Invalid username or password")
                    .foregroundColor(.red)
            }

            Button("Login") {
                if store.login(username: username, password: isParentLogin ? password : "") {
                    loginSuccess = true
                    showError = false
                } else {
                    showError = true
                }
            }
            .buttonStyle(.borderedProminent)

            if isParentLogin && store.currentParent == nil {
                Button("Register Parent") {
                    showingRegister = true
                }
                .buttonStyle(.bordered)
            }

            NavigationLink("", destination: ContentView(), isActive: $loginSuccess)
                .hidden()

            NavigationLink("", destination: RegisterView().environmentObject(store), isActive: $showingRegister)
                .hidden()
        }
        .padding()
    }
}

#Preview {
    let store = HousePointStore()
    return LoginView()
        .environmentObject(store)
}
