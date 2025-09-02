import CoreData

enum TestPersistence {
    
    static func makeInMemoryContainer(modelName: String = "Model") -> NSPersistentContainer {
        let container = NSPersistentContainer(name: modelName)
        let desc = NSPersistentStoreDescription()
        desc.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [desc]
        container.loadPersistentStores { _, error in
            precondition(error == nil, "Failed to load in-memory store: \(String(describing: error))")
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }
    
}
