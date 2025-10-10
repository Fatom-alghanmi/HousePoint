import SwiftUI

struct KidDashboardView: View {
    @EnvironmentObject var store: HousePointStore
    let currentUserId: UUID
    
    var body: some View {
        VStack {
            if let user = store.users.first(where: { $0.id == currentUserId }) {
                Text("Hi \(user.username)!")
                    .font(.largeTitle)
                    .padding()
                Text("Stars: \(user.points) ⭐")
                    .font(.title2)
            }
            
            List {
                ForEach(store.chores.filter { $0.assignedTo == currentUserId && !$0.isCompleted }) { chore in
                    ChoreRow(chore: chore)
                        .environmentObject(store)
                }
            }
        }
        .padding()
    }
}
