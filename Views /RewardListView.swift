import SwiftUI

struct RewardListView: View {
    @EnvironmentObject var store: HousePointStore

    var body: some View {
        List {
            ForEach(store.rewards) { reward in
                HStack {
                    Text(reward.name)
                    Spacer()
                    Text("\(reward.cost) ⭐")
                        .foregroundColor(.yellow)
                }
            }
        }
        .navigationTitle("Rewards")
    }
}

#Preview {
    let mockStore = HousePointStore()

    // Sample rewards
    let sampleRewards = [
        Reward(id: UUID(), name: "Extra Screen Time", cost: 10),
        Reward(id: UUID(), name: "Ice Cream", cost: 5),
        Reward(id: UUID(), name: "Movie Night", cost: 15)
    ]

    mockStore.rewards = sampleRewards

    return RewardListView()
        .environmentObject(mockStore)
}
