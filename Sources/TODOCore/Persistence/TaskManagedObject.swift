@preconcurrency import CoreData
import Foundation

@objc(TaskManagedObject)
public final class TaskManagedObject: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var remoteID: NSNumber?
    @NSManaged public var title: String
    @NSManaged public var detailsText: String
    @NSManaged public var createdAt: Date
    @NSManaged public var isCompleted: Bool
}

public extension TaskManagedObject {
    static let entityName = "TaskManagedObject"

    static func fetchRequestForTasks() -> NSFetchRequest<TaskManagedObject> {
        NSFetchRequest<TaskManagedObject>(entityName: entityName)
    }

    static func makeManagedObjectModel() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()
        let entity = NSEntityDescription()
        entity.name = entityName
        entity.managedObjectClassName = NSStringFromClass(TaskManagedObject.self)

        let idAttribute = NSAttributeDescription()
        idAttribute.name = "id"
        idAttribute.attributeType = .UUIDAttributeType
        idAttribute.isOptional = false

        let remoteIDAttribute = NSAttributeDescription()
        remoteIDAttribute.name = "remoteID"
        remoteIDAttribute.attributeType = .integer64AttributeType
        remoteIDAttribute.isOptional = true

        let titleAttribute = NSAttributeDescription()
        titleAttribute.name = "title"
        titleAttribute.attributeType = .stringAttributeType
        titleAttribute.isOptional = false

        let detailsAttribute = NSAttributeDescription()
        detailsAttribute.name = "detailsText"
        detailsAttribute.attributeType = .stringAttributeType
        detailsAttribute.isOptional = false

        let createdAtAttribute = NSAttributeDescription()
        createdAtAttribute.name = "createdAt"
        createdAtAttribute.attributeType = .dateAttributeType
        createdAtAttribute.isOptional = false

        let completedAttribute = NSAttributeDescription()
        completedAttribute.name = "isCompleted"
        completedAttribute.attributeType = .booleanAttributeType
        completedAttribute.isOptional = false

        entity.properties = [
            idAttribute,
            remoteIDAttribute,
            titleAttribute,
            detailsAttribute,
            createdAtAttribute,
            completedAttribute
        ]

        model.entities = [entity]
        return model
    }

    func toTaskItem() -> TaskItem {
        TaskItem(
            id: id,
            remoteID: remoteID?.intValue,
            title: title,
            details: detailsText,
            createdAt: createdAt,
            isCompleted: isCompleted
        )
    }
}
