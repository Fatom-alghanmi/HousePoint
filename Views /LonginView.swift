import SwiftUI

struct LoginView: View {
    @EnvironmentObject var store: HousePointStore

    var body: some View {
        NavigationView {
            ZStack {
                // 🌙 Soft Dark Background
                LinearGradient(
                    colors: [Color.black, Color(red: 0.12, green: 0.12, blue: 0.18)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 30) {

                    Spacer()

                    // 🏠 App Title
                    VStack(spacing: 8) {
                        Text("HousePoint")
                            .font(.system(size: 42, weight: .bold))
                            .foregroundColor(.white)

                        Text("Turn chores into rewards ⭐")
                            .foregroundColor(.gray)
                    }

                    Spacer()

                    // 👨‍👩‍👧 Login Buttons
                    VStack(spacing: 18) {
                        NavigationLink {
                            ParentLoginView()
                        } label: {
                            Label("Parent Login", systemImage: "lock.shield")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)

                        NavigationLink {
                            KidLoginView()
                        } label: {
                            Label("Kid Login", systemImage: "star.fill")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                    }

                    Divider()
                        .background(Color.gray.opacity(0.3))
                        .padding(.horizontal)

                    // 📝 Register Parent
                    NavigationLink {
                        RegisterView()
                    } label: {
                        Text("Register Parent")
                            .foregroundColor(.gray)
                    }

                    Spacer()
                }
                .padding()
            }
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(HousePointStore())
}
