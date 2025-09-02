import SwiftUI

struct ToDoListView: View {
    
    var items: [ToDoItem]
    var onSelect: (ToDoItem) -> Void
    var onToggle: (Int64) -> Void
    var onDelete: (Int64) -> Void
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                ForEach(items) { item in
                    let shareItem = shareText(for: item)
                    
                    ToDoRowView(note: item, onToggle: { onToggle(item.id) })
                        .contentShape(Rectangle())
                        .onTapGesture { onSelect(item) }
                        .contextMenu(menuItems: {
                            
                            Button("Редактировать", systemImage: "square.and.pencil") {
                                onSelect(item)
                            }
                            
                            ShareLink(item: shareItem,
                                      subject: Text(item.title),
                                      message: Text(item.content ?? "")) {
                                Label("Поделиться", systemImage: "square.and.arrow.up")
                            }
                            
                            Button(role: .destructive) {
                                onDelete(item.id)
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
    
    private func shareText(for item: ToDoItem) -> String {
        var lines: [String] = [item.title]
        if let content = item.content, !content.isEmpty {
            lines.append(content)
        }
        lines.append(item.date)
        return lines.joined(separator: "\n\n")
    }
    
}
