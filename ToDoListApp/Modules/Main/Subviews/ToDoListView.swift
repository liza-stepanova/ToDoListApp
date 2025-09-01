import SwiftUI

struct ToDoListView: View {
    
    var items: [ToDoItem]
    var onSelect: (ToDoItem) -> Void
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                ForEach(items) { item in
                    ToDoRowView(note: item, onToggle: {})
                        .contentShape(Rectangle())
                        .onTapGesture { onSelect(item) }
                        .contextMenu(menuItems: {
                            Button("Редактировать", systemImage: "square.and.pencil") {
                                // edit
                            }
                            Button("Поделиться",  systemImage: "square.and.arrow.up") {
                                // share
                            }
                            Button(role: .destructive) {
                                // delete
                            } label: {
                                Label("Удалить", systemImage: "trash")
                            }
                        }, preview: {
                            ContextView(item: item)
                        })
                    Divider()
                        .background(Color.contour)
                        .padding(.vertical, 12)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
        .padding(.bottom, 28)
    }
    
}
