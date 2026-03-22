@preconcurrency import CoreData
import Foundation

public final class CoreDataStack {
    public let persistentContainer: NSPersistentContainer

    public init(inMemory: Bool = false, storeURL: URL? = nil) throws {
        persistentContainer = NSPersistentContainer(
            name: "TODOModel",
            managedObjectModel: TaskManagedObject.makeManagedObjectModel()
        )

        let description = persistentContainer.persistentStoreDescriptions.first ?? NSPersistentStoreDescription()
        if inMemory {
            description.type = NSInMemoryStoreType
            description.url = URL(fileURLWithPath: "/dev/null")
        } else if let storeURL {
            description.url = storeURL
        }

        description.shouldInferMappingModelAutomatically = true
        description.shouldMigrateStoreAutomatically = true
        persistentContainer.persistentStoreDescriptions = [description]

        var loadError: Error?
        persistentContainer.loadPersistentStores { _, error in
            loadError = error
        }

        if let loadError {
            throw loadError
        }

        persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
        persistentContainer.viewContext.mergePolicy = NSMergePolicy(merge: .mergeByPropertyObjectTrumpMergePolicyType)
    }
}
