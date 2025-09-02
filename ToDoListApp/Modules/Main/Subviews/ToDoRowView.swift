import SwiftUI

struct ToDoRowView: View {
    
    var note: ToDoItem
    let onToggle: () -> Void
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Button(action: onToggle) {
                Image(systemName: note.isDone ? "checkmark.circle" : "circle")
                    .font(.system(size: 24, weight: .light))
                    .foregroundStyle(note.isDone ? Color.accent : Color.contour)
            }
            .padding(.top, -4)
            .buttonStyle(.plain)
                
            VStack(alignment: .leading, spacing: 6) {
                Text(note.title)
                    .rowTitleFont()
                    
                if let content = note.content, !content.isEmpty {
                    Text(content)
                        .subtitleFont()
                        .lineLimit(2)
                }
                
                Text(note.date)
                    .subtitleFont()
                    .opacity(0.5)
            }
            
            Spacer(minLength: 0)
                
        }
        .contentShape(Rectangle())
    }
}

//#Preview {
//    ToDoRowView(note: Note(id: 4, title: "ff", date: "34/32", isDone: true), onToggle: {})
//}
