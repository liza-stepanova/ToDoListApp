import SwiftUI

enum DetailBuilder {
    
    static func build(todoID: Int64) -> some View {
        let adapter = DetailViewAdapter()
        let interactor = DetailInteractor()
        let router = DetailRouter()
        let presenter = DetailPresenter(view: adapter, interactor: interactor, router: router, id: todoID)
        interactor.output = presenter
        
        return DetailModuleView(adapter: adapter, presenter: presenter, router: router)
    }
    
}
