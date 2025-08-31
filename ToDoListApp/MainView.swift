import SwiftUI

struct MainView: View {
    
    @State var items: [Note] = [
        Note(id: 1, title: "lala", content: "dd", date: "12/12/12", isDone: false),
        Note(id: 2, title: "laddddfla", content: "ddsfsdsfejdfkjfkddkfjhnjkfjknfnfnfnfnnfnfnfnfnfnfnnfnfnfnfnfnfnfnfnfnfnfnfnfnfnfnfnfnffkfkfkfkfkfkfkffkfkfkfkffkkkffkfwfwd", date: "12/12/12", isDone: false),
        Note(id: 3, title: "lala", content: "dd", date: "12/12/12", isDone: true),
        Note(id: 4, title: "lala", content: "dd", date: "12/12/12", isDone: false),
        Note(id: 5, title: "lala", content: "dd", date: "12/12/12", isDone: false),
        Note(id: 6, title: "lala", content: "dd", date: "12/12/12", isDone: true),
        Note(id: 7, title: "lala", content: "dd", date: "12/12/12", isDone: false)
    ]
    @State var searchText: String = ""
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                ToDoListView(items: $items)
                
                FooterView(countItems: items.count)
            }
            .navigationTitle("Задачи")
            
        }
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
    }
}

#Preview {
    MainView()
}
