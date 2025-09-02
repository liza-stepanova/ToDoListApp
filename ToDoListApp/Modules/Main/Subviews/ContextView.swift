import SwiftUI

struct ContextView: View {
    var item: ToDoItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(item.title)
                .rowTitleFont()
                .foregroundStyle(.white)
            if let content = item.content {
                Text(content)
                    .subtitleFont()
                    .foregroundStyle(.white)
                    .lineLimit(6)
            }
            Text(item.date)
                .subtitleFont()
                .foregroundStyle(.white)
                .opacity(0.5)
        }
        .frame(idealWidth: 300, maxWidth: 340, alignment: .leading)
        .padding(16)
        .background(Color.base,
                    in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
    
}
