import Foundation

final class DetailPresenter: DetailPresenterInput {
    
    private weak var view: DetailViewInput?
    private let interactor: DetailInteractorInput
    private let router: DetailRouterInput
    private var shouldCloseAfterSave = false
    private let mode: DetailMode

    private var current = DetailViewState()
    
    init(view: DetailViewInput,
         interactor: DetailInteractorInput,
         router: DetailRouterInput,
         mode: DetailMode) {
        self.view = view
        self.interactor = interactor
        self.router = router
        self.mode = mode
    }
    
    func onAppear() {
        view?.display(.init(isSaving: false))
        switch mode {
        case .create:
            interactor.load(todoID: 0)
        case .view(let id):
            interactor.load(todoID: id)
        }
    }
    
    func backTapped() {
        router.close()
        saveTapped()
    }
    
    func titleChanged(_ text: String) {
        current.title = text
        view?.display(current)
        interactor.saveDraft(todoID: 0, title: current.title, content: current.content)
    }
    
    func contentChanged(_ text: String) {
        current.content = text
        view?.display(current)
        interactor.saveDraft(todoID: 0, title: current.title, content: current.content)
    }
    
    func saveTapped() {
        view?.display(current.with(isSaving: true))
        switch mode {
        case .create:
            interactor.persist(todoID: 0)
        case .view(let id):
            interactor.persist(todoID: id)
        }
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
        case .success:
            view?.display(current.with(isSaving: false))
            if shouldCloseAfterSave { router.close() }
        case .failure(let error):
            view?.display(current.with(isSaving: false, error: error.localizedDescription))
            shouldCloseAfterSave = false
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
