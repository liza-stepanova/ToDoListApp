import XCTest
@testable import ToDoListApp

private final class ViewSpy: DetailViewInput {
    
    var states: [DetailViewState] = []
    func display(_ state: DetailViewState) { states.append(state) }
    var last: DetailViewState? { states.last }
    
}

private final class InteractorSpy: DetailInteractorInput {

    var loadedIDs: [Int64] = []
    var savedDrafts: [(id: Int64, title: String, content: String)] = []
    var persistedIDs: [Int64] = []

    func load(todoID: Int64) { loadedIDs.append(todoID) }
    
    func saveDraft(todoID: Int64, title: String, content: String) {
        savedDrafts.append((todoID, title, content))
    }
    
    func persist(todoID: Int64) { persistedIDs.append(todoID) }
}

private final class RouterSpy: DetailRouterInput {
    
    var closeCount = 0
    func close() { closeCount += 1 }
    
}

final class DetailPresenterTests: XCTestCase {
    
    private func makeSUT(mode: DetailMode) -> (sut: DetailPresenter, view: ViewSpy, interactor: InteractorSpy, router: RouterSpy) {
        let view = ViewSpy()
        let interactor = InteractorSpy()
        let router = RouterSpy()
        let sut = DetailPresenter(view: view, interactor: interactor, router: router, mode: mode)
        return (sut, view, interactor, router)
    }
    
    func test_onAppear_inCreate_callsLoadWithZero_andDisplaysNotSaving() {
        let (sut, view, interactor, _) = makeSUT(mode: .create)
        
        sut.onAppear()
        
        XCTAssertEqual(interactor.loadedIDs, [0])
        XCTAssertEqual(view.states.first?.isSaving, false)
    }
    
    func test_onAppear_inView_callsLoadWithPassedID() {
        let (sut, _, interactor, _) = makeSUT(mode: .view(777))
        sut.onAppear()
        XCTAssertEqual(interactor.loadedIDs, [777])
    }
    
    func test_didLoad_success_populatesViewState() {
        let (sut, view, _, _) = makeSUT(mode: .view(1))
        let item = ToDoItem(id: 1, title: "Title", content: "Body", date: "01/01/25", isDone: false)
        
        sut.didLoad(.success(item))
        
        XCTAssertEqual(view.last?.title, "Title")
        XCTAssertEqual(view.last?.content, "Body")
        XCTAssertEqual(view.last?.dateText, "01/01/25")
        XCTAssertEqual(view.last?.isSaving, false)
        XCTAssertNil(view.last?.error)
    }
    
    func test_didLoad_failure_setsError() {
        let (sut, view, _, _) = makeSUT(mode: .view(1))
        sut.didLoad(.failure(NSError(domain: "err", code: -1)))
        XCTAssertNotNil(view.last?.error)
    }
    
    func test_titleChanged_updatesState_and_callsSaveDraft_withZeroID() {
        let (sut, view, interactor, _) = makeSUT(mode: .view(123))
        sut.titleChanged("Hello")
        
        XCTAssertEqual(view.last?.title, "Hello")
        XCTAssertEqual(interactor.savedDrafts.last?.id, 0)
        XCTAssertEqual(interactor.savedDrafts.last?.title, "Hello")
    }
    
    func test_contentChanged_updatesState_and_callsSaveDraft_withZeroID() {
        let (sut, view, interactor, _) = makeSUT(mode: .create)
        sut.contentChanged("Long body")
        
        XCTAssertEqual(view.last?.content, "Long body")
        XCTAssertEqual(interactor.savedDrafts.last?.id, 0)
        XCTAssertEqual(interactor.savedDrafts.last?.content, "Long body")
    }
    
    func test_saveTapped_inCreate_setsSavingTrue_and_callsPersistZero() {
        let (sut, view, interactor, _) = makeSUT(mode: .create)
        
        sut.saveTapped()
        
        XCTAssertEqual(view.last?.isSaving, true)
        XCTAssertEqual(interactor.persistedIDs, [0])
    }
    
    func test_saveTapped_inView_callsPersistWithID() {
        let (sut, _, interactor, _) = makeSUT(mode: .view(5))
        sut.saveTapped()
        XCTAssertEqual(interactor.persistedIDs, [5])
    }
    
    func test_backTapped_closesImmediately_andCallsPersist() {
        let (sut, view, interactor, router) = makeSUT(mode: .view(9))
        
        sut.backTapped()
        
        XCTAssertEqual(router.closeCount, 1, "Экран закрылся сразу")
        XCTAssertEqual(interactor.persistedIDs, [9], "После закрытия всё равно вызывается сохранение")
        XCTAssertEqual(view.last?.isSaving, true, "Поставлен флаг сохранения")
    }
    
    func test_didPersist_success_stopsSaving_and_doesNotCloseAgain_whenFlagIsDefaultFalse() {
        let (sut, view, interactor, router) = makeSUT(mode: .view(3))
        
        sut.backTapped()
        sut.didPersist(.success(()))
        
        XCTAssertEqual(view.last?.isSaving, false)
        XCTAssertEqual(router.closeCount, 1, "Повторного закрытия нет (флаг не выставлялся)")
        XCTAssertEqual(interactor.persistedIDs, [3])
    }
    
    func test_didPersist_failure_setsError_and_doesNotClose() {
        let (sut, view, _, router) = makeSUT(mode: .create)
        
        sut.saveTapped()
        sut.didPersist(.failure(NSError(domain: "save", code: -2)))
        
        XCTAssertEqual(view.last?.isSaving, false)
        XCTAssertNotNil(view.last?.error)
        XCTAssertEqual(router.closeCount, 0)
    }
}
