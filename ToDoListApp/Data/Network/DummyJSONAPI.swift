import Foundation

struct ToDosPayload: Decodable {
    
    let todos: [ToDoDTO]
    
}

struct ToDoDTO: Decodable {
    
    let id: Int
    let todo: String
    let completed: Bool
    let userId: Int
    
}

enum DummyJSONAPI {
    
    static func fetchTodos(session: URLSession = .shared,
                           completion: @escaping (Result<[ToDoDTO], Error>) -> Void) {
        let url = URL(string: "https://dummyjson.com/todos")!
        let task = session.dataTask(with: url) { data, response, error in
            if let error = error { return completion(.failure(error)) }
            guard let data = data else {
                return completion(.failure(NSError(domain: "net", code: -1)))
            }
            do {
                let payload = try JSONDecoder().decode(
                    ToDosPayload.self,
                    from: data
                )
                completion(.success(payload.todos))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
}
