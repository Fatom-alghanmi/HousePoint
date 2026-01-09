import SwiftUI

struct AddChildView: View {
    @EnvironmentObject var store: HousePointStore
    @Environment(\.presentationMode) var presentationMode

    @State private var username = ""
    @State private var showError = false

    var body: some View {
        ZStack {
            LinearGradient(colors: [Color.purple.opacity(0.3), Color.blue.opacity(0.3)],
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Text("Add New Child")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.white)
                    .padding(.top)

                VStack(spacing: 16) {
                    TextField("Child's username", text: $username)
                        .padding()
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(10)
                        .shadow(radius: 3)

                    if showError {
                        Text("Please enter a valid name.")
                            .foregroundColor(.red)
                    }

                    Button(action: addChild) {
                        Text("Add Child")
                            .bold()
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.green)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                    }
                }
                .padding()
                .background(Color.black.opacity(0.3))
                .cornerRadius(20)
                .shadow(radius: 10)

                Spacer()
            }
            .padding()
        }
    }

    private func addChild() {
        if store.addChild(username: username) {
            presentationMode.wrappedValue.dismiss()
        } else {
            showError = true
        }
    }
}
