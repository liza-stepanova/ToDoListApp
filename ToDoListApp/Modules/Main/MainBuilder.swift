import Foundation
import SwiftUI

enum MainBuilder {
    
    static func build() -> some View {
        let adapter = MainViewAdapter()
        let interactor = MainInteractor()
        let router = MainRouter()
        let presenter = MainPresenter(view: adapter, interactor: interactor, router: router)
        interactor.output = presenter
        
        let root = MainView(adapter: adapter, presenter: presenter)
        return MainModuleView(root: root, router: router)
    }
    
}

private struct MainModuleView: View {
    
    @State private var path = NavigationPath()
    let root: MainView
    let router: MainRouter

    var body: some View {
        NavigationStack(path: $path) {
            root
                .onAppear {
                    router.pushToDoID = { id in path.append(id) }
                }
                .navigationDestination(for: Int64.self) { todoID in
                    DetailBuilder.build(todoID: todoID)
                }
        }
    }
    
}
