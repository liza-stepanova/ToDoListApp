import XCTest
import CoreData
@testable import ToDoListApp

final class CoreDataTodoRepositoryTests: XCTestCase {

    var container: NSPersistentContainer!
    var session: URLSession!
    var repo: CoreDataTodoRepository!

    override func setUp() {
        super.setUp()
        container = TestPersistence.makeInMemoryContainer()
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [URLProtocolMock.self]
        session = URLSession(configuration: config)
        repo = CoreDataTodoRepository(container: container, urlSession: session)
    }

    override func tearDown() {
        repo = nil
        session.invalidateAndCancel()
        session = nil
        container = nil
        super.tearDown()
    }

    func test_initialLoad_importsFromAPI_whenEmptyStore() {
        let jsonURL = Bundle(for: Self.self).url(forResource: "DummyTodos", withExtension: "json")!
        let data = try! Data(contentsOf: jsonURL)
        URLProtocolMock.requestHandler = { request in
            let resp = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (resp, data)
        }

        let exp = expectation(description: "initial load")
        repo.initialLoadIfNeeded { result in
            switch result {
            case .failure(let error): XCTFail("initialLoad error: \(error)")
            case .success:
                self.repo.fetchAll { result in
                    switch result {
                    case .failure(let error): XCTFail("fetch error: \(error)")
                    case .success(let items):
                        XCTAssertEqual(items.count, 2)
                        XCTAssertEqual(items.first?.title, "Buy milk")
                    }
                    exp.fulfill()
                }
            }
        }
        wait(for: [exp], timeout: 1.0)
    }

    func test_upsert_fetch_search_setDone_delete() {
        let exp = expectation(description: "crud")
        let item = ToDoItem(id: 42, title: "Test", content: "Body", date: "01/01/25", isDone: false)

        repo.upsert(item) { upsertResult in
            if case .failure(let error) = upsertResult { return XCTFail("upsert error \(error)") }

            self.repo.fetchAll { fetchResult in
                guard case .success(let items) = fetchResult else { return XCTFail("fetch fail") }
                XCTAssertEqual(items.count, 1)

                self.repo.search("Tes") { searchResult in
                    guard case .success(let found) = searchResult else { return XCTFail("search fail") }
                    XCTAssertEqual(found.first?.id, 42)

                    self.repo.setDone(id: 42, done: true) { setResult in
                        if case .failure(let error) = setResult { return XCTFail("setDone error \(error)") }

                        self.repo.delete(id: 42) { delResult in
                            if case .failure(let error) = delResult { return XCTFail("delete error \(error)") }
                            self.repo.fetchAll { r in
                                guard case .success(let left) = r else { return XCTFail("fetch after delete fail") }
                                XCTAssertTrue(left.isEmpty)
                                exp.fulfill()
                            }
                        }
                    }
                }
            }
        }

        wait(for: [exp], timeout: 1.0)
    }
}
