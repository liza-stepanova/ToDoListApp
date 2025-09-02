import SwiftUI

enum DetailBuilder {
    
    static func build(mode: DetailMode) -> some View {
        let adapter = DetailViewAdapter()
        let repository = CoreDataTodoRepository(container: PersistenceController.shared)
        let interactor = DetailInteractor(repository: repository, mode: mode)
        let router = DetailRouter()
        let presenter = DetailPresenter(view: adapter, interactor: interactor, router: router, mode: mode)
        interactor.output = presenter
        
        return DetailModuleView(adapter: adapter, presenter: presenter, router: router)
    }
    
}

enum DetailMode: Equatable {
    
    case view(Int64)
    case create
    
}
