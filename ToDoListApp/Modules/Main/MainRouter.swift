import Foundation

final class MainRouter: MainRouterInput {
    
    var pushToDoID: ((Int64) -> Void)?
    
    func showDetails(todoID: Int64) {
        pushToDoID?(todoID)
    }
    func showCreate() {
        // 
    }
    
}
