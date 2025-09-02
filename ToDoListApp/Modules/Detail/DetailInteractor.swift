import Foundation

final class DetailInteractor: DetailInteractorInput {
    
    weak var output: DetailInteractorOutput?
    private let repository: ToDoRepository
    
    private var current: ToDoItem?
    private var draftTitle: String = ""
    private var draftContent: String = ""
    
    init(repository: ToDoRepository) {
        self.repository = repository
    }

    func load(todoID: Int64) {
        repository.fetchByID(todoID) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(let e):
                DispatchQueue.main.async { self.output?.didLoad(.failure(e)) }
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

    func saveDraft(todoID: Int64, title: String, content: String) {
        draftTitle = title
        draftContent = content
    }

    func persist(todoID: Int64) {
        let base = current
        let updated = ToDoItem(
            id: todoID,
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
                case .failure(let e):
                    self.output?.didPersist(.failure(e))
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
