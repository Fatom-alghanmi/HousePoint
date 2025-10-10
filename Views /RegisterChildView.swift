//
//  RegisterChildView.swift
//  HousePoint
//
//  Created by Fatom on 2025-10-10.
//

import SwiftUI

struct RegisterChildView: View {
    @EnvironmentObject var store: HousePointStore
    @Environment(\.presentationMode) var presentationMode

    @State private var username = ""
    @State private var showError = false
    @State private var errorMessage = ""

    var body: some View {
        VStack(spacing: 20) {
            Text("Register New Child")
                .font(.largeTitle)
                .padding()

            TextField("Child's Username", text: $username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            if showError {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding()
            }

            Button("Register") {
                if username.trimmingCharacters(in: .whitespaces).isEmpty {
                    errorMessage = "Please enter a username."
                    showError = true
                    return
                }

                if store.addChild(username: username) {
                    presentationMode.wrappedValue.dismiss()
                } else {
                    errorMessage = "Username taken or invalid."
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
    return RegisterChildView()
        .environmentObject(store)
}
