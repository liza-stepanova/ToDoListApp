import Foundation
import SwiftUI

enum MainBuilder {
    
    static func build() -> some View {
        let adapter = MainViewAdapter()
        let interactor = MainInteractor()
        let router = MainRouter()
        let presenter = MainPresenter(view: adapter, interactor: interactor, router: router)
        interactor.output = presenter
        return MainView(adapter: adapter, presenter: presenter)
    }
    
}
