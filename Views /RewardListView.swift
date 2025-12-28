import SwiftUI

struct RewardListView: View {
    @EnvironmentObject var store: HousePointStore

    var body: some View {
        List {
            ForEach(store.rewardsInFamily) { reward in
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
