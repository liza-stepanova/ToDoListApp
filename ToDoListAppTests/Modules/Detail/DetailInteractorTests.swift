import XCTest
@testable import ToDoListApp

private final class DetailOutputSpy: DetailInteractorOutput {
    
    var loadResults: [Result<ToDoItem, Error>] = []
    var loadOnMain: [Bool] = []

    var persistResults: [Result<Void, Error>] = []
    var persistOnMain: [Bool] = []

    var onLoad: ((Result<ToDoItem, Error>) -> Void)?
    var onPersist: ((Result<Void, Error>) -> Void)?

    func didLoad(_ result: Result<ToDoItem, Error>) {
        loadResults.append(result)
        loadOnMain.append(Thread.isMainThread)
        onLoad?(result)
    }

    func didPersist(_ result: Result<Void, Error>) {
        persistResults.append(result)
        persistOnMain.append(Thread.isMainThread)
        onPersist?(result)
    }
    
}

private final class RepoSpy: ToDoRepository {
    
    var fetchByIDCalledWith: [Int64] = []
    var lastUpsertedItem: ToDoItem?

    var fetchByIDResult: Result<ToDoItem, Error> = .failure(NSError(domain: "no", code: 404))
    var upsertResult: Result<Void, Error> = .success(())

    func fetchByID(_ id: Int64, completion: @escaping (Result<ToDoItem, Error>) -> Void) {
        fetchByIDCalledWith.append(id)
        DispatchQueue.global(qos: .userInitiated).async {
            completion(self.fetchByIDResult)
        }
    }

    func upsert(_ item: ToDoItem, completion: @escaping (Result<Void, Error>) -> Void) {
        lastUpsertedItem = item
        DispatchQueue.global(qos: .userInitiated).async {
            completion(self.upsertResult)
        }
    }

    func initialLoadIfNeeded(completion: @escaping (Result<Void, Error>) -> Void) { completion(.success(())) }
    
    func fetchAll(completion: @escaping (Result<[ToDoItem], Error>) -> Void) { completion(.success([])) }
    
    func search(_ query: String, completion: @escaping (Result<[ToDoItem], Error>) -> Void) { completion(.success([])) }
    
    func setDone(id: Int64, done: Bool, completion: @escaping (Result<Void, Error>) -> Void) { completion(.success(())) }
    
    func delete(id: Int64, completion: @escaping (Result<Void, Error>) -> Void) { completion(.success(())) }
}

final class DetailInteractorTests: XCTestCase {

    private func makeSUT(mode: DetailMode, repo: RepoSpy = RepoSpy())
    -> (sut: DetailInteractor, repo: RepoSpy, out: DetailOutputSpy) {
        let sut = DetailInteractor(repository: repo, mode: mode)
        let out = DetailOutputSpy()
        sut.output = out
        return (sut, repo, out)
    }


    func test_load_create_emitsEmptyItemOnMain() {
        let (sut, repo, out) = makeSUT(mode: .create)

        let exp = expectation(description: "didLoad create")
        out.onLoad = { _ in exp.fulfill() }

        sut.load(todoID: 0)

        wait(for: [exp], timeout: 1.0)
        XCTAssertTrue(repo.fetchByIDCalledWith.isEmpty, "В .create не должен вызываться fetchByID")
        let item = try? out.loadResults.last?.get()
        XCTAssertEqual(item?.id, 0)
        XCTAssertEqual(item?.title, "")
        XCTAssertEqual(item?.isDone, false)
        XCTAssertNotNil(item?.date)
        XCTAssertEqual(out.loadOnMain.last, true, "UI-события должны приходить на main")
    }

    func test_load_view_fetchesByID_andDeliversItemOnMain_success() {
        let (sut, repo, out) = makeSUT(mode: .view(777))
        let base = ToDoItem(id: 777, title: "T", content: "C", date: "D", isDone: true)
        repo.fetchByIDResult = .success(base)

        let exp = expectation(description: "didLoad view")
        out.onLoad = { _ in exp.fulfill() }

        sut.load(todoID: 777)

        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(repo.fetchByIDCalledWith, [777])
        let item = try? out.loadResults.last?.get()
        XCTAssertEqual(item?.id, 777)
        XCTAssertEqual(item?.title, "T")
        XCTAssertEqual(item?.content, "C")
        XCTAssertEqual(item?.date, "D")
        XCTAssertEqual(item?.isDone, true)
        XCTAssertEqual(out.loadOnMain.last, true)
    }

    func test_load_view_deliversFailureOnMain_whenRepoFails() {
        let (sut, repo, out) = makeSUT(mode: .view(1))
        repo.fetchByIDResult = .failure(NSError(domain: "fetch", code: -1))

        let exp = expectation(description: "didLoad fail")
        out.onLoad = { _ in exp.fulfill() }

        sut.load(todoID: 1)

        wait(for: [exp], timeout: 1.0)
        XCTAssertNotNil(out.loadResults.last?.failure)
        XCTAssertEqual(out.loadOnMain.last, true)
    }

    func test_persist_create_generatesNonZeroID_trimsTitle_keepsContent_andSendsSuccessOnMain() {
        let (sut, repo, out) = makeSUT(mode: .create)

        let expLoad = expectation(description: "load create")
        out.onLoad = { _ in expLoad.fulfill() }
        sut.load(todoID: 0)
        wait(for: [expLoad], timeout: 1.0)

        sut.saveDraft(todoID: 0, title: "  Hello  ", content: "  Body  ")

        let expPersist = expectation(description: "persist create")
        out.onPersist = { _ in expPersist.fulfill() }
        sut.persist(todoID: 0)
        wait(for: [expPersist], timeout: 1.0)

        let saved = repo.lastUpsertedItem
        XCTAssertNotNil(saved)
        XCTAssertNotEqual(saved?.id, 0, "В create должен генерироваться ненулевой id")
        XCTAssertEqual(saved?.title, "Hello")
        XCTAssertEqual(saved?.content, "  Body  ", "Контент не триммим")
        XCTAssertFalse(saved?.date.isEmpty ?? true, "Дата должна быть задана")
        XCTAssertEqual(saved?.isDone, false, "В create базовое значение isDone = false")
        XCTAssertEqual(out.persistResults.last?.isSuccess, true)
        XCTAssertEqual(out.persistOnMain.last, true)
    }

    func test_persist_view_usesSameID_keepsBaseDateAndDone_andSendsSuccessOnMain() {
        let id: Int64 = 9
        let (sut, repo, out) = makeSUT(mode: .view(id))

        let base = ToDoItem(id: id, title: "Old", content: "Prev", date: "DATE", isDone: true)
        repo.fetchByIDResult = .success(base)

        let expLoad = expectation(description: "load view")
        out.onLoad = { _ in expLoad.fulfill() }
        sut.load(todoID: id)
        wait(for: [expLoad], timeout: 1.0)

        sut.saveDraft(todoID: id, title: "  New  ", content: "")

        let expPersist = expectation(description: "persist view")
        out.onPersist = { _ in expPersist.fulfill() }
        sut.persist(todoID: id)
        wait(for: [expPersist], timeout: 1.0)

        let saved = repo.lastUpsertedItem
        XCTAssertEqual(saved?.id, id)
        XCTAssertEqual(saved?.title, "New")
        XCTAssertNil(saved?.content, "Пустая строка")
        XCTAssertEqual(saved?.date, "DATE")
        XCTAssertEqual(saved?.isDone, true)
        XCTAssertEqual(out.persistResults.last?.isSuccess, true)
        XCTAssertEqual(out.persistOnMain.last, true)
    }

    func test_persist_failure_deliversFailureOnMain() {
        let (sut, repo, out) = makeSUT(mode: .create)
        let expLoad = expectation(description: "load create")
        out.onLoad = { _ in expLoad.fulfill() }
        sut.load(todoID: 0)
        wait(for: [expLoad], timeout: 1.0)

        repo.upsertResult = .failure(NSError(domain: "save", code: -2))

        let expPersist = expectation(description: "persist fail")
        out.onPersist = { _ in expPersist.fulfill() }
        sut.persist(todoID: 0)
        wait(for: [expPersist], timeout: 1.0)

        XCTAssertNotNil(out.persistResults.last?.failure)
        XCTAssertEqual(out.persistOnMain.last, true)
    }
}

private extension Result {
    var failure: Failure? {
        if case let .failure(e) = self { return e }
        return nil
    }
    var isSuccess: Bool {
        if case .success = self { return true } else { return false }
    }
}
