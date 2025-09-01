import Foundation

final class DetailPresenter: DetailPresenterInput {
    
    private weak var view: DetailViewInput?
    private let interactor: DetailInteractorInput
    private let router: DetailRouterInput
    private let id: Int64

    private var current = DetailViewState()
    
    init(view: DetailViewInput, interactor: DetailInteractorInput, router: DetailRouterInput, id: Int64) {
        self.view = view
        self.interactor = interactor
        self.router = router
        self.id = id
    }
    
    func onAppear() {
        view?.display(.init(isSaving: false))
        interactor.load(todoID: id)
    }
    
    func backTapped() {
        router.close()
    }
    
    func titleChanged(_ text: String) {
        current.title = text
        view?.display(current)
        interactor.saveDraft(todoID: id, title: current.title, content: current.content)
    }
    
    func contentChanged(_ text: String) {
        current.content = text
        view?.display(current)
        interactor.saveDraft(todoID: id, title: current.title, content: current.content)
    }
    
    func saveTapped() {
        view?.display(current.with(isSaving: true))
        interactor.persist(todoID: id)
    }
    
}

extension DetailPresenter: DetailInteractorOutput {
    
    func didLoad(_ result: Result<ToDoItem, Error>) {
        switch result {
        case .success(let item):
            current = .init(title: item.title,
                            content: item.content ?? "",
                            dateText: item.date,
                            isSaving: false,
                            error: nil)
            view?.display(current)
        case .failure(let e):
            view?.display(.init(error: e.localizedDescription))
        }
    }

    func didPersist(_ result: Result<Void, Error>) {
        switch result {
        case .success: view?.display(current.with(isSaving: false))
        case .failure(let e): view?.display(current.with(isSaving: false, error: e.localizedDescription))
        }
    }
    
}

private extension DetailViewState {
    
    func with(isSaving: Bool? = nil, error: String? = nil) -> Self {
        var s = self
        if let v = isSaving { s.isSaving = v }
        if let e = error { s.error = e }
        return s
    }
    
}
