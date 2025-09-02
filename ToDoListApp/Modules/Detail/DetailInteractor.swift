import Foundation

final class DetailInteractor: DetailInteractorInput {
    
    weak var output: DetailInteractorOutput?
    private let repository: ToDoRepository
    
    private let mode: DetailMode
    private var current: ToDoItem?
    private var draftTitle: String = ""
    private var draftContent: String = ""
    
    init(repository: ToDoRepository, mode: DetailMode) {
        self.repository = repository
        self.mode = mode
    }

    func load(todoID: Int64) {
        switch mode {
        case .create:
            let empty = ToDoItem(
                id: 0,
                title: "",
                content: nil,
                date: Self.makeTodayString(),
                isDone: false
            )
            current = empty
            draftTitle = ""
            draftContent = ""
            DispatchQueue.main.async { self.output?.didLoad(.success(empty)) }

        case .view(let id):
            repository.fetchByID(id) { [weak self] result in
                guard let self else { return }
                switch result {
                case .failure(let error):
                    DispatchQueue.main.async { self.output?.didLoad(.failure(error)) }
                case .success(let item):
                    self.current = item
                    self.draftTitle = item.title
                    self.draftContent = item.content ?? ""
                    DispatchQueue.main.async {
                        self.output?.didLoad(.success(item))
                    }
                }
            }
        }
    }

    func saveDraft(todoID: Int64, title: String, content: String) {
        draftTitle = title
        draftContent = content
    }

    func persist(todoID: Int64) {
        let base = current
        let idToUse: Int64 = {
            switch mode {
            case .create:
                return Int64(Date().timeIntervalSince1970 * 1000)
            case .view(let id):
                return id
            }
        }()
        
        let updated = ToDoItem(
            id: idToUse,
            title: draftTitle.trimmingCharacters(in: .whitespacesAndNewlines),
            content: draftContent.isEmpty ? nil : draftContent,
            date: base?.date ?? Self.makeTodayString(),
            isDone: base?.isDone ?? false
        )

        repository.upsert(updated) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.current = updated
                    self.output?.didPersist(.success(()))
                case .failure(let error):
                    self.output?.didPersist(.failure(error))
                }
            }
        }
    }
    
    private static func makeTodayString() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: Date())
    }
    
}
