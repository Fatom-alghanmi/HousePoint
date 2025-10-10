//
//  AddRewardView.swift
//  HousePoint
//
//  Created by Fatom on 2025-10-10.
//

import SwiftUI

struct AddRewardView: View {
    @EnvironmentObject var store: HousePointStore
    @Environment(\.presentationMode) var presentationMode

    @State private var name = ""
    @State private var cost = ""
    @State private var showError = false

    var body: some View {
        VStack(spacing: 20) {
            Text("Add New Reward")
                .font(.largeTitle)
                .padding()

            TextField("Reward name", text: $name)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            TextField("Cost (stars)", text: $cost)
                .keyboardType(.numberPad)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            if showError {
                Text("Please enter valid data.")
                    .foregroundColor(.red)
            }

            Button("Add Reward") {
                if let costInt = Int(cost), !name.trimmingCharacters(in: .whitespaces).isEmpty {
                    store.rewards.append(Reward(id: UUID(), name: name, cost: costInt))
                    presentationMode.wrappedValue.dismiss()
                } else {
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
    return AddRewardView()
        .environmentObject(store)
}
