import Foundation

protocol MainViewInput: AnyObject {
    
    func display(_ state: MainViewState)
    
}

protocol MainPresenterInput {
    
    func onAppear()
    func toggleDone(id: Int64)
    func delete(id: Int64)
    func search(query: String)
    func addTapped()
    func openDetails(id: Int64)
    
}

protocol MainInteractorInput {
    
    func loadInitial()
    func setDone(_ id: Int64, _ done: Bool)
    func delete(_ id: Int64)
    func search(_ query: String)
    
}

protocol MainInteractorOutput: AnyObject {
    
    func didLoadInitial(_ result: Result<[ToDoItem], Error>)
    func didSetDone(_ result: Result<ToDoItem, Error>)
    func didDelete(_ result: Result<Int64, Error>)
    func didSearch(_ result: Result<[ToDoItem], Error>)
    
}

protocol MainRouterInput: AnyObject {
    
    func showDetails(todoID: Int64)
    func showCreate()
    
}
