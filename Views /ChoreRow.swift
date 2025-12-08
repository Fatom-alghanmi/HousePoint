import SwiftUI

struct ChoreRow: View {
    @EnvironmentObject var store: HousePointStore
    var chore: Chore
    
    var body: some View {
        HStack {
            if let image = chore.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            
            VStack(alignment: .leading) {
                Text(chore.title).font(.headline)
                if let desc = chore.description {
                    Text(desc).font(.subheadline).foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            if !chore.isCompleted && !chore.isMarkedDoneByChild {
                Button("Done") {
                    store.markChoreDoneByChild(chore)
                }
                .buttonStyle(.borderedProminent)
            }
            
            if chore.isMarkedDoneByChild {
                Text("Pending")
                    .foregroundColor(.orange)
            }
        }
    }
}
