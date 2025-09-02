import XCTest
@testable import ToDoListApp

private final class OutputSpy: MainInteractorOutput {
    
    var loadResults: [Result<[ToDoItem], Error>] = []
    var loadOnMain: [Bool] = []

    var setDoneResults: [Result<ToDoItem, Error>] = []
    var setDoneOnMain: [Bool] = []

    var deleteResults: [Result<Int64, Error>] = []
    var deleteOnMain: [Bool] = []

    var searchResults: [Result<[ToDoItem], Error>] = []
    var searchOnMain: [Bool] = []

    var onLoad: ((Result<[ToDoItem], Error>) -> Void)?
    var onSetDone: ((Result<ToDoItem, Error>) -> Void)?
    var onDelete: ((Result<Int64, Error>) -> Void)?
    var onSearch: ((Result<[ToDoItem], Error>) -> Void)?

    func didLoadInitial(_ result: Result<[ToDoItem], Error>) {
        loadResults.append(result)
        loadOnMain.append(Thread.isMainThread)
        onLoad?(result)
    }

    func didSetDone(_ result: Result<ToDoItem, Error>) {
        setDoneResults.append(result)
        setDoneOnMain.append(Thread.isMainThread)
        onSetDone?(result)
    }

    func didDelete(_ result: Result<Int64, Error>) {
        deleteResults.append(result)
        deleteOnMain.append(Thread.isMainThread)
        onDelete?(result)
    }

    func didSearch(_ result: Result<[ToDoItem], Error>) {
        searchResults.append(result)
        searchOnMain.append(Thread.isMainThread)
        onSearch?(result)
    }
}

private final class RepoSpy: ToDoRepository {
    
    var initialLoadCalled = false
    var fetchAllCalled = false
    var searchCalledWith: [String] = []
    var setDoneCalls: [(Int64, Bool)] = []
    var deleteCalls: [Int64] = []

    var initialLoadResult: Result<Void, Error> = .success(())
    var fetchAllResult: Result<[ToDoItem], Error> = .success([])
    var searchResult: Result<[ToDoItem], Error> = .success([])
    var setDoneResult: Result<Void, Error> = .success(())
    var deleteResult: Result<Void, Error> = .success(())

    func initialLoadIfNeeded(completion: @escaping (Result<Void, Error>) -> Void) {
        initialLoadCalled = true
        DispatchQueue.global(qos: .userInitiated).async {
            completion(self.initialLoadResult)
        }
    }

    func fetchAll(completion: @escaping (Result<[ToDoItem], Error>) -> Void) {
        fetchAllCalled = true
        DispatchQueue.global(qos: .userInitiated).async {
            completion(self.fetchAllResult)
        }
    }
    
    func fetchByID(_ id: Int64, completion: @escaping (Result<ToDoListApp.ToDoItem, any Error>) -> Void) {
        //
    }

    func search(_ query: String, completion: @escaping (Result<[ToDoItem], Error>) -> Void) {
        searchCalledWith.append(query)
        DispatchQueue.global(qos: .userInitiated).async {
            completion(self.searchResult)
        }
    }

    func setDone(id: Int64, done: Bool, completion: @escaping (Result<Void, Error>) -> Void) {
        setDoneCalls.append((id, done))
        DispatchQueue.global(qos: .userInitiated).async {
            completion(self.setDoneResult)
        }
    }

    func delete(id: Int64, completion: @escaping (Result<Void, Error>) -> Void) {
        deleteCalls.append(id)
        DispatchQueue.global(qos: .userInitiated).async {
            completion(self.deleteResult)
        }
    }

    func upsert(_ item: ToDoItem, completion: @escaping (Result<Void, Error>) -> Void) {
        DispatchQueue.global().async { completion(.success(())) }
    }
}

final class MainInteractorTests: XCTestCase {

    private func makeSUT(repo: RepoSpy = RepoSpy()) -> (MainInteractor, RepoSpy, OutputSpy) {
        let sut = MainInteractor(repository: repo)
        let out = OutputSpy()
        sut.output = out
        return (sut, repo, out)
    }

    func test_loadInitial_callsInitialLoadAndFetchAll_andDeliversOnMain_success() {
        let (sut, repo, out) = makeSUT()
        let items: [ToDoItem] = [
            .init(id: 1, title: "A", content: nil, date: "d", isDone: false),
            .init(id: 2, title: "B", content: "c", date: "d", isDone: true),
        ]
        repo.initialLoadResult = .success(())
        repo.fetchAllResult = .success(items)

        let exp = expectation(description: "didLoadInitial")
        out.onLoad = { _ in exp.fulfill() }

        sut.loadInitial()

        wait(for: [exp], timeout: 1.0)
        XCTAssertTrue(repo.initialLoadCalled)
        XCTAssertTrue(repo.fetchAllCalled)
        XCTAssertEqual(out.loadResults.last?.value ?? [], items)
        XCTAssertEqual(out.loadOnMain.last, true, "UI-события должны приходить на main.")
    }

    func test_loadInitial_ignoresInitialError_andReportsFetchAllResult() {
        let (sut, repo, out) = makeSUT()
        repo.initialLoadResult = .failure(NSError(domain: "x", code: -1))
        repo.fetchAllResult = .success([.init(id: 10, title: "T", content: nil, date: "d", isDone: false)])

        let exp = expectation(description: "didLoadInitial")
        out.onLoad = { _ in exp.fulfill() }

        sut.loadInitial()

        wait(for: [exp], timeout: 1.0)
        XCTAssertTrue(repo.fetchAllCalled)
        XCTAssertEqual(out.loadResults.last?.value??.count, 1)
        XCTAssertEqual(out.loadOnMain.last, true)
    }

    func test_setDone_success_fetchAll_success_reportsUpdatedItem_andNewList_onMain() {
        let (sut, repo, out) = makeSUT()
        let id: Int64 = 7
        repo.setDoneResult = .success(())
        let updated = ToDoItem(id: id, title: "Z", content: nil, date: "d", isDone: true)
        repo.fetchAllResult = .success([updated])

        let expSet = expectation(description: "didSetDone")
        let expLoad = expectation(description: "didLoadInitial after setDone")

        out.onSetDone = { _ in expSet.fulfill() }
        out.onLoad = { _ in expLoad.fulfill() }

        sut.setDone(id, true)

        wait(for: [expSet, expLoad], timeout: 1.0)
        XCTAssertEqual(repo.setDoneCalls.last?.0, id)
        XCTAssertEqual(repo.setDoneCalls.last?.1, true)
        XCTAssertEqual(out.setDoneResults.last?.value??.id, id)
        XCTAssertEqual(out.setDoneOnMain.last, true)
        XCTAssertEqual(out.loadResults.last?.value??.count, 1)
        XCTAssertEqual(out.loadOnMain.last, true)
    }

    func test_setDone_success_but_fetchAll_failure_reportsSetDoneFailure() {
        let (sut, repo, out) = makeSUT()
        repo.setDoneResult = .success(())
        repo.fetchAllResult = .failure(NSError(domain: "fetch", code: -2))

        let exp = expectation(description: "didSetDone fail")
        out.onSetDone = { _ in exp.fulfill() }

        sut.setDone(1, true)

        wait(for: [exp], timeout: 1.0)
        XCTAssertNotNil(out.setDoneResults.last?.error)
        XCTAssertEqual(out.setDoneOnMain.last, true)
    }

    func test_setDone_failure_reportsFailure_andDoesNotFetchAll() {
        let (sut, repo, out) = makeSUT()
        repo.setDoneResult = .failure(NSError(domain: "set", code: -3))

        let exp = expectation(description: "didSetDone fail")
        out.onSetDone = { _ in exp.fulfill() }

        sut.setDone(99, false)

        wait(for: [exp], timeout: 1.0)
        XCTAssertTrue(repo.fetchAllCalled == false)
        XCTAssertNotNil(out.setDoneResults.last?.error)
        XCTAssertEqual(out.setDoneOnMain.last, true)
    }
    
    func test_delete_success_fetchAll_success_reportsDeleteAndNewList_onMain() {
        let (sut, repo, out) = makeSUT()
        let id: Int64 = 42
        repo.deleteResult = .success(())
        repo.fetchAllResult = .success([.init(id: 1, title: "A", content: nil, date: "d", isDone: false)])

        let expDel = expectation(description: "didDelete")
        let expLoad = expectation(description: "didLoadInitial after delete")
        out.onDelete = { _ in expDel.fulfill() }
        out.onLoad = { _ in expLoad.fulfill() }

        sut.delete(id)

        wait(for: [expDel, expLoad], timeout: 1.0)
        XCTAssertEqual(repo.deleteCalls.last, id)
        XCTAssertEqual(out.deleteResults.last?.value ?? -1, id)
        XCTAssertEqual(out.deleteOnMain.last, true)
        XCTAssertEqual(out.loadOnMain.last, true)
    }

    func test_delete_success_but_fetchAll_failure_reportsDeleteFailure() {
        let (sut, repo, out) = makeSUT()
        repo.deleteResult = .success(())
        repo.fetchAllResult = .failure(NSError(domain: "fetch", code: -9))

        let exp = expectation(description: "didDelete fail")
        out.onDelete = { _ in exp.fulfill() }

        sut.delete(5)

        wait(for: [exp], timeout: 1.0)
        XCTAssertNotNil(out.deleteResults.last?.error)
        XCTAssertEqual(out.deleteOnMain.last, true)
    }

    func test_delete_failure_reportsFailure_andDoesNotFetchAll() {
        let (sut, repo, out) = makeSUT()
        repo.deleteResult = .failure(NSError(domain: "del", code: -1))

        let exp = expectation(description: "didDelete fail")
        out.onDelete = { _ in exp.fulfill() }

        sut.delete(100)

        wait(for: [exp], timeout: 1.0)
        XCTAssertFalse(repo.fetchAllCalled)
        XCTAssertNotNil(out.deleteResults.last?.error)
        XCTAssertEqual(out.deleteOnMain.last, true)
    }

    func test_search_forwardsRepositoryResult_onMain() {
        let (sut, repo, out) = makeSUT()
        let items = [ToDoItem(id: 1, title: "Milk", content: nil, date: "d", isDone: false)]
        repo.searchResult = .success(items)

        let exp = expectation(description: "didSearch")
        out.onSearch = { _ in exp.fulfill() }

        sut.search("mi")

        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(repo.searchCalledWith.last, "mi")
        XCTAssertEqual(out.searchResults.last?.value ?? [], items)
        XCTAssertEqual(out.searchOnMain.last, true)
    }
}

private extension Result {
    var value: Success?? {
        if case let .success(v) = self { return v }
        return nil
    }
    var error: Failure? {
        if case let .failure(e) = self { return e }
        return nil
    }
}
