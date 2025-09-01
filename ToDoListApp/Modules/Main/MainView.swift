import SwiftUI

struct MainView: View {
    
    @StateObject var adapter: MainViewAdapter
    let presenter: MainPresenterInput
    
    @State var searchText: String = ""
    
    var body: some View {
        
        ZStack(alignment: .bottom) {
            ToDoListView(
                items: adapter.state.items,
                onSelect: { item in
                    presenter.openDetails(id: item.id)
                }
            )
            FooterView(countItems: adapter.state.items.count)
        }
        .navigationTitle("Задачи")
        .onAppear { presenter.onAppear() }
        .searchable(
            text: $searchText,
            placement: .navigationBarDrawer(displayMode: .always)
        )
        
    }
    
}

//#Preview {
//    MainView()
//}
