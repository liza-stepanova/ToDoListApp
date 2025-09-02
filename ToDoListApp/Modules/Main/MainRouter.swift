import Foundation

final class MainRouter: MainRouterInput {
    
    var pushDetails: ((Int64) -> Void)?
    var pushCreate: (() -> Void)?
    
    func showDetails(todoID: Int64) {
        pushDetails?(todoID)
    }
    
    func showCreate() {
        pushCreate?()
    }
    
}
