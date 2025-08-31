import Foundation
import Combine

final class MainViewAdapter: ObservableObject, MainViewInput {
    
    @Published private(set) var state: MainViewState = .init()
    
    public init() {}
    
    func display(_ newState: MainViewState) {
        if Thread.isMainThread {
            state = newState
        } else {
            DispatchQueue.main.async { [weak self] in self?.state = newState }
        }
    }
    
}
