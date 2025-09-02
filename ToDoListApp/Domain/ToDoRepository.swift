import Foundation

protocol ToDoRepository {
    
    func initialLoadIfNeeded(completion: @escaping (Result<Void, Error>) -> Void)

    func fetchAll(completion: @escaping (Result<[ToDoItem], Error>) -> Void)
    
    func fetchByID(_ id: Int64, completion: @escaping (Result<ToDoItem, Error>) -> Void)

    func search(_ query: String, completion: @escaping (Result<[ToDoItem], Error>) -> Void)

    func setDone(id: Int64, done: Bool, completion: @escaping (Result<Void, Error>) -> Void)

    func upsert(_ item: ToDoItem, completion: @escaping (Result<Void, Error>) -> Void)

    func delete(id: Int64, completion: @escaping (Result<Void, Error>) -> Void)
    
}
