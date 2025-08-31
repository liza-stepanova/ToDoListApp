import Foundation

final class MainInteractor: MainInteractorInput {
    
    weak var output: MainInteractorOutput?
    
    func loadInitial() {
        DispatchQueue
            .global(qos: .userInitiated)
            .asyncAfter(deadline: .now() + 0.2) {
                let mock: [ToDoItem] = [
                    .init(
                        id: 1,
                        title: "Почитать книгу",
                        content: "Глава 3",
                        date: "09/10/24",
                        isDone: true
                    ),
                    .init(
                        id: 2,
                        title: "Сходить в зал",
                        content: "Тренировка ног",
                        date: "02/10/24",
                        isDone: false
                    ),
                ]
                self.output?.didLoadInitial(.success(mock))
            }
    }
    
    func setDone(_ id: Int64, _ done: Bool) {
        //
    }
    
    func delete(_ id: Int64) {
        //
    }
    
    func search(_ query: String) {
        //
    }
    
    
}
