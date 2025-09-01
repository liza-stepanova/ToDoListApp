import Foundation

final class DetailInteractor: DetailInteractorInput {
    
    weak var output: DetailInteractorOutput?
    // private let repo: TodoRepository

    func load(todoID: Int64) {
        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + 0.15) {
            let mock = ToDoItem(id: todoID,
                                title: "Заняться спортом",
                                content: "Составить список необходимых продуктов для ужина. Не забыть проверить, что уже есть в холодильнике.",
                                date: "02/10/24",
                                isDone: false)
            self.output?.didLoad(.success(mock))
        }
    }

    func saveDraft(todoID: Int64, title: String, content: String) {
        //
    }

    func persist(todoID: Int64) {
        // repo.update(...)
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.1) {
            self.output?.didPersist(.success(()))
        }
    }
}
