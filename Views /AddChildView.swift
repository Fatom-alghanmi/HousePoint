//
//  AddChildView.swift
//  HousePoint
//
//  Created by Fatom on 2025-10-10.
//

import SwiftUI

struct AddChildView: View {
    @EnvironmentObject var store: HousePointStore
    @Environment(\.presentationMode) var presentationMode

    @State private var username = ""
    @State private var showError = false

    var body: some View {
        VStack(spacing: 20) {
            Text("Add New Child")
                .font(.largeTitle)
                .padding()

            TextField("Child's username", text: $username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            if showError {
                Text("Please enter a valid name.")
                    .foregroundColor(.red)
            }

            Button("Add Child") {
                if store.addChild(username: username) {
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
    return AddChildView()
        .environmentObject(store)
}
