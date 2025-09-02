import CoreData

final class CoreDataTodoRepository: ToDoRepository {
    typealias API = (URLSession, @escaping (Result<[ToDoDTO], Error>) -> Void) -> Void
    
    private let container: NSPersistentContainer
    private let apiFetch: (_ session: URLSession, _ completion: @escaping (Result<[ToDoDTO], Error>) -> Void) -> Void
    private let urlSession: URLSession
    
    init(container: NSPersistentContainer,
         apiFetch: @escaping API = { session, completion in
            DummyJSONAPI.fetchTodos(session: session, completion: completion)
        },
         urlSession: URLSession = .shared) {
        self.container = container
        self.apiFetch = apiFetch
        self.urlSession = urlSession
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    func initialLoadIfNeeded(completion: @escaping (Result<Void, Error>) -> Void) {
        countInStore { [weak self] countResult in
            guard let self = self else { return }
            switch countResult {
            case .failure(let error):
                completion(.failure(error))
            case .success(let count):
                guard count == 0 else {
                    return completion(.success(()))
                }
                self.apiFetch(self.urlSession) { result in
                    switch result {
                    case .failure(let error):
                        completion(.failure(error))
                    case .success(let dtos):
                        self.importDTOs(dtos) { importResult in
                            completion(importResult)
                        }
                    }
                }
            }
        }
    }

    func fetchAll(completion: @escaping (Result<[ToDoItem], Error>) -> Void) {
        fetch(predicate: nil,
              sort: NSSortDescriptor(key: "date", ascending: false),
              completion: completion)
    }
    
    func fetchByID(_ id: Int64, completion: @escaping (Result<ToDoItem, Error>) -> Void) {
        container.performBackgroundTask { context in
            do {
                let req: NSFetchRequest<CDToDo> = CDToDo.fetchRequest()
                req.fetchLimit = 1
                req.predicate = NSPredicate(format: "id == %lld", id)
                guard let row = try context.fetch(req).first else {
                    return completion(.failure(NSError(domain: "repo",
                                                       code: 404,
                                                       userInfo: [NSLocalizedDescriptionKey: "Not found"]))
                    )
                }
                let item = ToDoItem(id: row.id,
                                    title: row.title ?? "",
                                    content: row.content,
                                    date: row.date ?? "",
                                    isDone: row.isDone)
                completion(.success(item))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func search(_ query: String,
                completion: @escaping (Result<[ToDoItem], Error>) -> Void) {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return fetchAll(completion: completion) }

        let predicate = NSCompoundPredicate(orPredicateWithSubpredicates: [
            NSPredicate(format: "title CONTAINS[cd] %@", trimmed),
            NSPredicate(format: "content CONTAINS[cd] %@", trimmed)
        ])
        fetch(predicate: predicate,
              sort: NSSortDescriptor(key: "date", ascending: false),
              completion: completion)
    }

    func setDone(id: Int64,
                 done: Bool,
                 completion: @escaping (Result<Void, Error>) -> Void) {
        let context = container.newBackgroundContext()
        context.perform {
            do {
                let req: NSFetchRequest<CDToDo> = CDToDo.fetchRequest()
                req.fetchLimit = 1
                req.predicate = NSPredicate(format: "id == %lld", id)
                if let obj = try context.fetch(req).first {
                    obj.isDone = done
                    try context.save()
                }
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func upsert(_ item: ToDoItem, completion: @escaping (Result<Void, Error>) -> Void) {
        let context = container.newBackgroundContext()
        context.perform {
            do {
                let req: NSFetchRequest<CDToDo> = CDToDo.fetchRequest()
                req.fetchLimit = 1
                req.predicate = NSPredicate(format: "id == %lld", item.id)
                let obj = try context.fetch(req).first ?? CDToDo(context: context)
                obj.id = item.id
                obj.title = item.title
                obj.content = item.content
                obj.date = item.date
                obj.isDone = item.isDone
                try context.save()
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func delete(id: Int64, completion: @escaping (Result<Void, Error>) -> Void) {
        let context = container.newBackgroundContext()
        context.perform {
            do {
                let req: NSFetchRequest<CDToDo> = CDToDo.fetchRequest()
                req.fetchLimit = 1
                req.predicate = NSPredicate(format: "id == %lld", id)
                if let obj = try context.fetch(req).first {
                    context.delete(obj)
                    try context.save()
                }
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
}

private extension CoreDataTodoRepository {
    
    func countInStore(completion: @escaping (Result<Int, Error>) -> Void) {
        container.performBackgroundTask { context in
            do {
                let req = NSFetchRequest<NSNumber>(entityName: "CDToDo")
                req.resultType = .countResultType
                let count = try context.count(for: req)
                completion(.success(count))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    func fetch(predicate: NSPredicate?,
               sort: NSSortDescriptor,
               completion: @escaping (Result<[ToDoItem], Error>) -> Void) {
        container.performBackgroundTask { context in
            do {
                let req: NSFetchRequest<CDToDo> = CDToDo.fetchRequest()
                req.predicate = predicate
                req.sortDescriptors = [sort]
                let rows = try context.fetch(req)
                let items = rows.map {
                    ToDoItem(id: $0.id,
                             title: $0.title ?? "",
                             content: $0.content,
                             date: $0.date ?? "",
                             isDone: $0.isDone)
                }
                completion(.success(items))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func importDTOs(_ dtos: [ToDoDTO],
                    completion: @escaping (Result<Void, Error>) -> Void) {
        container.performBackgroundTask { context in
            do {
                for dto in dtos {
                    let obj = CDToDo(context: context)
                    obj.id = Int64(dto.id)
                    obj.title = dto.todo
                    obj.content = nil
                    obj.isDone = dto.completed
                    obj.date = Self.makeTodayString()
                }
                try context.save()
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    static func makeTodayString() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: Date())
    }
    
}
