import SwiftUI

struct ChoreRow: View {
    @EnvironmentObject var store: HousePointStore
    var chore: Chore

    var body: some View {
        HStack {
            Text(chore.title)
            Spacer()
            if !chore.isCompleted {
                Button("Done") {
                    store.approveChore(chore)
                }
                .buttonStyle(.bordered)
            } else {
                Text("✅")
            }
        }
    }
}
#Preview {
    let store = HousePointStore()
    store.registerParent(username: "parent", password: "1234")
    store.addChild(username: "child")

    return ChoreRow(chore: store.chores.first ?? Chore(id: UUID(), title: "Sample", assignedTo: nil, isCompleted: false))
        .environmentObject(store)
}

