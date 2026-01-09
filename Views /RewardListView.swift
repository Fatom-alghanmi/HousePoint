import SwiftUI

struct RewardListView: View {
    @EnvironmentObject var store: HousePointStore

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(store.rewardsInFamily) { reward in
                    HStack {
                        Text(reward.name)
                            .bold()
                            .foregroundColor(.white)
                        Spacer()
                        Text("\(reward.cost) ⭐")
                            .foregroundColor(.yellow)
                            .bold()
                    }
                    .padding()
                    .background(Color.orange.opacity(0.7))
                    .cornerRadius(15)
                    .shadow(radius: 5)
                }
            }
            .padding()
        }
        .navigationTitle("Rewards")
        .background(
            LinearGradient(
                colors: [Color.yellow.opacity(0.2), Color.orange.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        )
    }
}
