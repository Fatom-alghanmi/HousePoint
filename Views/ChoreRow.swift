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
                    store.completeChore(chore)
                }
                .buttonStyle(.bordered)
            } else {
                Text("✅")
            }
        }
    }
}
