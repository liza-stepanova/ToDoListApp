import Foundation
import Combine

final class DetailViewAdapter: ObservableObject, DetailViewInput {
    
    @Published private(set) var state: DetailViewState = .init()
    
    func display(_ newState: DetailViewState) {
        if Thread.isMainThread {
            state = newState
        } else {
            DispatchQueue.main.async { [weak self] in self?.state = newState }
        }
    }

}
