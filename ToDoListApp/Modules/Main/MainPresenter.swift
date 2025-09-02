import Foundation

final class MainPresenter: MainPresenterInput {
    
    private weak var view: MainViewInput?
    private let interactor: MainInteractorInput
    private let router: MainRouterInput
    
    private var current = MainViewState()
    
    init(view: MainViewInput, interactor: MainInteractorInput, router: MainRouterInput) {
        self.view = view
        self.interactor = interactor
        self.router = router
    }
    
    func onAppear() {
        view?.display(.init(items: [], isLoading: true, error: nil))
        interactor.loadInitial()
    }
    
    func toggleDone(id: Int64) {
        let newDone = !(current.items.first{ $0.id == id }?.isDone ?? false)
        interactor.setDone(id, newDone)
    }
    
    func delete(id: Int64) {
        interactor.delete(id)
    }
    
    func search(query: String) {
        interactor.search(query)
    }
    
    func addTapped() {
        router.showCreate()
    }
    
    func openDetails(id: Int64) {
        router.showDetails(todoID: id)
    }
    
}

extension MainPresenter: MainInteractorOutput {
    
    func didLoadInitial(_ result: Result<[ToDoItem], any Error>) {
        switch result {
        case .success(let items):
            current = .init(items: items, isLoading: false, error: nil)
            view?.display(current)
        case .failure(let error):
            current = .init(items: [], isLoading: false, error: error.localizedDescription)
            view?.display(current)
        }
    }
    
    func didSetDone(_ result: Result<ToDoItem, any Error>) {
        switch result {
        case .success(let updated):
            if let idx = current.items.firstIndex(where: { $0.id == updated.id}) {
                current.items[idx] = updated
            }
            current.error = nil
            view?.display(current)

        case .failure(let error):
            var s = current
            s.error = error.localizedDescription
            view?.display(s)
        }
    }
    
    func didDelete(_ result: Result<Int64, any Error>) {
        switch result {
        case .success(let id):
            current.items.removeAll { $0.id == id }
            current.error = nil
            view?.display(current)

        case .failure(let error):
            var s = current
            s.error = error.localizedDescription
            view?.display(s)
        }
    }
    
    func didSearch(_ result: Result<[ToDoItem], any Error>) {
        switch result {
        case .success(let items):
            current.items = items
            view?.display(current)
        case .failure(let error):
            view?.display(.init(items: [], isLoading: false, error: error.localizedDescription))
        }
    }
    
}
