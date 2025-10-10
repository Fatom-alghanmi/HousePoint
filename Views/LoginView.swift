import SwiftUI

struct LoginView: View {
    @EnvironmentObject var store: HousePointStore
    @State private var username = ""
    @State private var password = ""
    @State private var loginSuccess = false

    var body: some View {
        VStack {
            Text("Welcome to HousePoint")
                .font(.largeTitle)
                .padding()

            TextField("Username", text: $username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button("Login") {
                if store.login(username: username, password: password) {
                    loginSuccess = true
                }
            }
            .buttonStyle(.borderedProminent)
            .padding()
            
            NavigationLink("", destination: nextView(), isActive: $loginSuccess)
                .hidden()
        }
        .padding()
    }
    
    @ViewBuilder
    func nextView() -> some View {
        if let user = store.currentUser {
            if user.isParent {
                ParentDashboardView()
                    .environmentObject(store)
            } else {
                KidDashboardView(currentUserId: user.id)
                    .environmentObject(store)
            }
        }
    }
}
