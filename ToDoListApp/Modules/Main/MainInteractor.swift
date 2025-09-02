import Foundation

final class MainInteractor: MainInteractorInput {
    
    weak var output: MainInteractorOutput?
    private let repository: ToDoRepository
    
    init(repository: ToDoRepository) {
        self.repository = repository
    }
    
    func loadInitial() {
        repository.initialLoadIfNeeded { [weak self] _ in
            self?.repository.fetchAll { result in
                DispatchQueue.main.async {
                    self?.output?.didLoadInitial(result)
                }
            }
        }
    }
    
    func setDone(_ id: Int64, _ done: Bool) {
        repository.setDone(id: id, done: done) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
                case .success:
                self.repository.fetchAll { listResult in
                    switch listResult {
                    case .success(let items):
                        let updated = items.first { $0.id == id } ?? ToDoItem(id: id, title: "", date: "", isDone: done)
                        DispatchQueue.main.async {
                            self.output?.didSetDone(.success(updated))
                            self.output?.didLoadInitial(.success(items))
                        }
                    case .failure(let error):
                        DispatchQueue.main.async {
                            self.output?.didSetDone(.failure(error))
                        }
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.output?.didSetDone(.failure(error))
                }
            }
        }
    }
    
    func delete(_ id: Int64) {
        repository.delete(id: id, completion: { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success:
                self.repository.fetchAll { listResult in
                    switch listResult {
                    case .success(let items):
                        DispatchQueue.main.async {
                            self.output?.didDelete(.success(id))
                            self.output?.didLoadInitial(.success(items))
                        }
                    case .failure(let error):
                        DispatchQueue.main.async {
                            self.output?.didDelete(.failure(error))
                        }
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.output?.didDelete(.failure(error))
                }
            }
        })
    }
    
    func search(_ query: String) {
        repository.search(query) { [weak self] result in
            DispatchQueue.main.async {
                self?.output?.didSearch(result)
            }
        }
    }
    
}
