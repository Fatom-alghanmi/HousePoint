import SwiftUI

struct AddRewardView: View {
    @EnvironmentObject var store: HousePointStore
    @State private var name = ""
    @State private var cost = 10

    var body: some View {
        ZStack {
            LinearGradient(colors: [Color.orange.opacity(0.3), Color.yellow.opacity(0.2)],
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Text("Add New Reward")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.white)
                    .padding(.top)

                VStack(spacing: 16) {
                    TextField("Reward name", text: $name)
                        .padding()
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(10)
                        .shadow(radius: 3)

                    Stepper("Cost: \(cost) ⭐", value: $cost, in: 1...100)
                        .padding()
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(10)
                        .shadow(radius: 3)

                    Button(action: addReward) {
                        Text("Add Reward")
                            .bold()
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(LinearGradient(colors: [Color.red, Color.orange],
                                                       startPoint: .leading,
                                                       endPoint: .trailing))
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

    private func addReward() {
        guard let familyId = store.currentFamilyId else { return }

        let reward = Reward(
            id: UUID(),
            name: name,
            cost: cost,
            familyId: familyId
        )

        store.rewards.append(reward)
        store.saveData()
        name = ""
        cost = 10
    }
}
