import XCTest
@testable import ToDoListApp

private final class ViewSpy: MainViewInput {
    
    var states: [MainViewState] = []
    func display(_ state: MainViewState) { states.append(state) }
    
}

private final class InteractorSpy: MainInteractorInput {
    
    weak var output: MainInteractorOutput?

    var loadCalled = false
    var setDoneArgs: (Int64, Bool)?
    var deleteArg: Int64?
    var searchArg: String?

    func loadInitial() { loadCalled = true }
    func setDone(_ id: Int64, _ done: Bool) { setDoneArgs = (id, done) }
    func delete(_ id: Int64) { deleteArg = id }
    func search(_ query: String) { searchArg = query }
    
}

private final class RouterSpy: MainRouterInput {
    
    var shownDetails: Int64?
    var didShowCreate = false

    func showDetails(todoID: Int64) { shownDetails = todoID }
    func showCreate() { didShowCreate = true }
    
}

final class MainPresenterTests: XCTestCase {

    private func makeSUT() -> (sut: MainPresenter,
                               view: ViewSpy,
                               interactor: InteractorSpy,
                               router: RouterSpy)
    {
        let view = ViewSpy()
        let interactor = InteractorSpy()
        let router = RouterSpy()
        let sut = MainPresenter(view: view, interactor: interactor, router: router)
        interactor.output = sut
        return (sut, view, interactor, router)
    }

    func test_onAppear_setsLoadingAndCallsLoad() {
        let (sut, view, interactor, _) = makeSUT()

        sut.onAppear()

        XCTAssertTrue(interactor.loadCalled)
        XCTAssertEqual(view.states.first?.isLoading, true)
    }

    func test_didLoadInitial_success_updatesState() {
        let (sut, view, _, _) = makeSUT()
        let items: [ToDoItem] = [
            .init(id: 1, title: "A", content: nil, date: "d", isDone: false),
            .init(id: 2, title: "B", content: "c", date: "d", isDone: true)
        ]

        sut.didLoadInitial(.success(items))

        XCTAssertEqual(view.states.last?.items, items)
        XCTAssertEqual(view.states.last?.isLoading, false)
        XCTAssertNil(view.states.last?.error)
    }

    func test_didLoadInitial_failure_setsErrorAndClearsItems() {
        let (sut, view, _, _) = makeSUT()

        sut.didLoadInitial(.failure(NSError(domain: "x", code: 1)))

        XCTAssertEqual(view.states.last?.items.count, 0)
        XCTAssertNotNil(view.states.last?.error)
        XCTAssertEqual(view.states.last?.isLoading, false)
    }

    func test_toggleDone_calculatesNewValueAndCallsInteractor() {
        let (sut, _, interactor, _) = makeSUT()
        sut.didLoadInitial(.success([.init(id: 7, title: "X", content: nil, date: "d", isDone: false)]))

        sut.toggleDone(id: 7)

        XCTAssertEqual(interactor.setDoneArgs?.0, 7)
        XCTAssertEqual(interactor.setDoneArgs?.1, true)
    }

    func test_didSetDone_success_updatesOneItem() {
        let (sut, view, _, _) = makeSUT()
        sut.didLoadInitial(.success([
            .init(id: 1, title: "A", content: nil, date: "d", isDone: false),
            .init(id: 2, title: "B", content: nil, date: "d", isDone: false)
        ]))

        let updated = ToDoItem(id: 2, title: "B", content: nil, date: "d", isDone: true)
        sut.didSetDone(.success(updated))

        XCTAssertEqual(view.states.last?.items[1].isDone, true)
        XCTAssertNil(view.states.last?.error)
    }

    func test_didSetDone_failure_setsError_keepsItems() {
        let (sut, view, _, _) = makeSUT()
        sut.didLoadInitial(.success([
            .init(id: 1, title: "A", content: nil, date: "d", isDone: false)
        ]))

        sut.didSetDone(.failure(NSError(domain: "err", code: -1)))

        XCTAssertEqual(view.states.last?.items.count, 1)
        XCTAssertNotNil(view.states.last?.error)
    }

    func test_delete_callsInteractor_and_didDelete_removesItem() {
        let (sut, view, interactor, _) = makeSUT()
        sut.didLoadInitial(.success([.init(id: 1, title: "A", content: nil, date: "d", isDone: false)]))

        sut.delete(id: 1)
        XCTAssertEqual(interactor.deleteArg, 1)

        sut.didDelete(.success(1))
        XCTAssertTrue(view.states.last?.items.isEmpty ?? false)
        XCTAssertNil(view.states.last?.error)
    }

    func test_didDelete_failure_setsError_keepsItems() {
        let (sut, view, _, _) = makeSUT()
        sut.didLoadInitial(.success([.init(id: 1, title: "A", content: nil, date: "d", isDone: false)]))

        sut.didDelete(.failure(NSError(domain: "del", code: -2)))

        XCTAssertEqual(view.states.last?.items.count, 1)
        XCTAssertNotNil(view.states.last?.error)
    }

    func test_search_forwardsToInteractor() {
        let (sut, _, interactor, _) = makeSUT()
        sut.search(query: "ab")
        XCTAssertEqual(interactor.searchArg, "ab")
    }

    func test_openDetails_routesWithCorrectID_and_addTapped_routesToCreate() {
        let (sut, _, _, router) = makeSUT()

        sut.openDetails(id: 42)
        XCTAssertEqual(router.shownDetails, 42)

        sut.addTapped()
        XCTAssertTrue(router.didShowCreate)
    }
    
}
