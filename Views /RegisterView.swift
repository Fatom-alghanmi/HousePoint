import SwiftUI

struct RegisterView: View {
    @EnvironmentObject var store: HousePointStore
    @Environment(\.presentationMode) var presentationMode

    @State private var username = ""
    @State private var password = ""
    @State private var showError = false
    @State private var errorMessage = ""

    var body: some View {
        VStack(spacing: 20) {
            Text("Register Parent Account")
                .font(.largeTitle)
                .padding()

            TextField("Username", text: $username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            if showError {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding()
            }

            Button("Register") {
                if username.trimmingCharacters(in: .whitespaces).isEmpty ||
                   password.isEmpty {
                    errorMessage = "Please fill in both fields."
                    showError = true
                    return
                }

                if store.registerParent(username: username, password: password) {
                    presentationMode.wrappedValue.dismiss()
                } else {
                    errorMessage = "Registration failed. Only one parent allowed or username taken."
                    showError = true
                }
            }
            .buttonStyle(.borderedProminent)
            .padding()
        }
    }
}

#Preview {
    let store = HousePointStore()
    return RegisterView()
        .environmentObject(store)
}
