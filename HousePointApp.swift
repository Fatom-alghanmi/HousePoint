



import SwiftUI

@main
struct HousePointApp: App {
    @StateObject private var store = HousePointStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
        }
    }
}
