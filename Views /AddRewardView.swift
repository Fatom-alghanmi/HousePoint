//
//  AddRewardView.swift
//  HousePoint
//
//  Created by Fatom on 2025-10-10.
//

import SwiftUI

import SwiftUI

struct AddRewardView: View {
    @EnvironmentObject var store: HousePointStore
    @State private var name = ""
    @State private var cost = 10

    var body: some View {
        VStack(spacing: 16) {
            Text("Add New Reward")
                .font(.title)

            TextField("Reward name", text: $name)
                .textFieldStyle(.roundedBorder)

            Stepper("Cost: \(cost) ⭐", value: $cost, in: 1...100)

            Button("Add Reward") {
                guard let familyId = store.currentFamilyId else { return }

                let reward = Reward(
                    id: UUID(),
                    name: name,
                    cost: cost,
                    familyId: familyId   // ✅ REQUIRED
                )

                store.rewards.append(reward)
                store.saveData()

                name = ""
                cost = 10
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

#Preview {
    let store = HousePointStore()
    return AddRewardView()
        .environmentObject(store)
}
