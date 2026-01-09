import SwiftUI

struct ParentLoginView: View {
    @EnvironmentObject var store: HousePointStore

    @State private var username = ""
    @State private var password = ""
    @State private var errorMessage = ""
    @State private var navigateToDashboard = false

    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [Color.blue.opacity(0.6), Color.purple.opacity(0.5)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // Header
                    VStack {
                        Text("🛡️ Parent Login")
                            .font(.largeTitle)
                            .bold()
                            .foregroundColor(.white)
                        Text("Manage your kids' chores and rewards")
                            .foregroundColor(.white.opacity(0.9))
                            .font(.subheadline)
                    }
                    .padding(.bottom, 30)
                    
                    // Login form in a card
                    VStack(spacing: 16) {
                        TextField("Username", text: $username)
                            .padding()
                            .background(Color.white.opacity(0.9))
                            .cornerRadius(10)
                            .shadow(radius: 3)
                        
                        SecureField("Password", text: $password)
                            .padding()
                            .background(Color.white.opacity(0.9))
                            .cornerRadius(10)
                            .shadow(radius: 3)
                        
                        Button(action: {
                            let success = store.login(username: username, password: password)
                            if success {
                                errorMessage = ""
                                navigateToDashboard = true
                            } else {
                                errorMessage = "Invalid username or password"
                            }
                        }) {
                            Text("Login")
                                .bold()
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(
                                    LinearGradient(colors: [Color.orange, Color.red],
                                                   startPoint: .leading,
                                                   endPoint: .trailing)
                                )
                                .cornerRadius(10)
                                .shadow(radius: 5)
                        }
                        
                        if !errorMessage.isEmpty {
                            Text(errorMessage)
                                .foregroundColor(.red)
                        }
                    }
                    .padding()
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(20)
                    .shadow(radius: 10)
                    .padding(.horizontal, 20)
                    
                    Spacer()
                }
                .padding(.top, 50)
                
                // Invisible navigation link
                NavigationLink(
                    destination: ParentDashboardView().environmentObject(store),
                    isActive: $navigateToDashboard
                ) { EmptyView() }
            }
        }
    }
}
