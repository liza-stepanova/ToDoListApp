import SwiftUI

struct MainView: View {
    
    @StateObject var adapter: MainViewAdapter
    let presenter: MainPresenterInput
    @State var searchText: String = ""
    
    var body: some View {
        
        ZStack(alignment: .bottom) {
            ToDoListView(
                items: adapter.state.items,
                onSelect: { presenter.openDetails(id: $0.id) },
                onToggle: { presenter.toggleDone(id: $0) },
                onDelete: { presenter.delete(id: $0) }
            )
            FooterView(countItems: adapter.state.items.count)
        }
        .navigationTitle("Задачи")
        .onAppear { presenter.onAppear() }
        .searchable(
            text: $searchText,
            placement: .navigationBarDrawer(displayMode: .always)
        )
        .onChange(of: searchText) { oldValue, newValue in
            presenter.search(query: newValue)
        }
        
    }
    
}

//#Preview {
//    MainView()
//}
