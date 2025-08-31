import Foundation

final class MainPresenter: MainPresenterInput {
    
    private weak var view: MainViewInput?
    private let interactor: MainInteractorInput
    private let router: MainRouterInput
    
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
        //
    }
    
    func delete(id: Int64) {
        //
    }
    
    func search(query: String) {
        //
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
            view?.display(.init(items: items, isLoading: false, error: nil))
        case .failure(let error):
            view?.display(.init(items: [], isLoading: false, error: error.localizedDescription))
        }
    }
    
    func didSetDone(_ result: Result<ToDoItem, any Error>) {
        //
    }
    
    func didDelete(_ result: Result<Int64, any Error>) {
        //
    }
    
    func didSearch(_ result: Result<[ToDoItem], any Error>) {
        //
    }
    
}
