import CoreData

enum PersistenceController {
    
    static let shared: NSPersistentContainer = make()
    
    static func make(inMemory: Bool = false) -> NSPersistentContainer {
        let container = NSPersistentContainer(name: "Model")
        
        if inMemory {
            let desc = NSPersistentStoreDescription()
            desc.type = NSInMemoryStoreType
            container.persistentStoreDescriptions = [desc]
        }
        
        container.loadPersistentStores { _, error in
            if let error = error{
                fatalError("CoreData store load failed: \(error)")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }
    
}
