//
//  LonginView.swift
//  HousePoint
//
//  Created by Fatom on 2025-12-24.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var store: HousePointStore

    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Text("HousePoint")
                    .font(.system(size: 40, weight: .bold))
                    .padding(.top, 50)

                NavigationLink("Parent Login") {
                    ParentLoginView()
                }
                .buttonStyle(.borderedProminent)

                NavigationLink("Kid Login") {
                    KidLoginView()
                }
                .buttonStyle(.bordered)

                Divider()
                    .padding(.horizontal)

                NavigationLink("Register Parent") {
                    RegisterView()
                }
                .buttonStyle(.bordered)

                Spacer()
            }
            .padding()
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(HousePointStore())
}
