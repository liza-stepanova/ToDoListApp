import Foundation

final class DetailRouter: DetailRouterInput {
    
    var closeHandler: (() -> Void)?
    
    func close() {
        closeHandler?()
    }
    
}
