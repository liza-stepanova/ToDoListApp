import Foundation
import SwiftUI

enum MainBuilder {
    
    static func build() -> some View {
        let adapter = MainViewAdapter()
        let repository = CoreDataTodoRepository(container: PersistenceController.shared)
        let interactor = MainInteractor(repository: repository)
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
                    router.pushDetails = { id in path.append(Route.details(id)) }
                    router.pushCreate = { path.append(Route.create) }
                }
                .navigationDestination(for: Route.self) { route in
                    switch route {
                    case .details(let id):
                        DetailBuilder.build(mode: .view(id))
                    case .create:
                        DetailBuilder.build(mode: .create)
                    }
                }
        }
    }
    
}
