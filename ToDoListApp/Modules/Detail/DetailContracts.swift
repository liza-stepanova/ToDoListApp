import Foundation

protocol DetailViewInput: AnyObject {
    
    func display(_ state: DetailViewState)
    
}

protocol DetailPresenterInput {
    
    func onAppear()
    func backTapped()
    func titleChanged(_ text: String)
    func contentChanged(_ text: String)
    func saveTapped()
    
}

protocol DetailInteractorInput {
    
    func load(todoID: Int64)
    func saveDraft(todoID: Int64, title: String, content: String)
    func persist(todoID: Int64)
    
}

protocol DetailInteractorOutput: AnyObject {
    
    func didLoad(_ result: Result<ToDoItem, Error>)
    func didPersist(_ result: Result<Void, Error>)
    
}

protocol DetailRouterInput: AnyObject {
    
    func close()
    
}
