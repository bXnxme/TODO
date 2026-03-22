@preconcurrency import CoreData
import Foundation

public final class CoreDataTaskRepository: TaskRepository, @unchecked Sendable {
    private let persistentContainer: NSPersistentContainer
    private let callbackQueue: DispatchQueue

    public init(coreDataStack: CoreDataStack, callbackQueue: DispatchQueue = .main) {
        self.persistentContainer = coreDataStack.persistentContainer
        self.callbackQueue = callbackQueue
    }

    public func fetchTasks(
        matching query: String?,
        completion: @escaping (Result<[TaskItem], Error>) -> Void
    ) {
        let completionBox = UncheckedSendableBox(completion)

        persistentContainer.performBackgroundTask { [weak self, completionBox] context in
            guard let self else { return }

            do {
                let request = TaskManagedObject.fetchRequestForTasks()
                request.sortDescriptors = [
                    NSSortDescriptor(key: "createdAt", ascending: false),
                    NSSortDescriptor(key: "title", ascending: true)
                ]

                if let query = self.normalized(query) {
                    request.predicate = NSCompoundPredicate(orPredicateWithSubpredicates: [
                        NSPredicate(format: "title CONTAINS[cd] %@", query),
                        NSPredicate(format: "detailsText CONTAINS[cd] %@", query)
                    ])
                }

                let tasks = try context.fetch(request).map { $0.toTaskItem() }
                self.complete(.success(tasks), completionBox: completionBox)
            } catch {
                self.complete(.failure(error), completionBox: completionBox)
            }
        }
    }

    public func fetchTask(
        id: UUID,
        completion: @escaping (Result<TaskItem, Error>) -> Void
    ) {
        let completionBox = UncheckedSendableBox(completion)

        persistentContainer.performBackgroundTask { [weak self, completionBox] context in
            guard let self else { return }

            do {
                let task = try self.fetchManagedTask(id: id, in: context)
                self.complete(.success(task.toTaskItem()), completionBox: completionBox)
            } catch {
                self.complete(.failure(error), completionBox: completionBox)
            }
        }
    }

    public func saveTask(
        _ draft: TaskDraft,
        taskID: UUID?,
        completion: @escaping (Result<TaskItem, Error>) -> Void
    ) {
        let completionBox = UncheckedSendableBox(completion)

        persistentContainer.performBackgroundTask { [weak self, completionBox] context in
            guard let self else { return }

            context.mergePolicy = NSMergePolicy(merge: .mergeByPropertyObjectTrumpMergePolicyType)

            do {
                let taskObject: TaskManagedObject
                if let taskID {
                    taskObject = try self.fetchManagedTask(id: taskID, in: context)
                } else {
                    taskObject = TaskManagedObject(context: context)
                    taskObject.id = UUID()
                    taskObject.createdAt = Date()
                    taskObject.remoteID = nil
                }

                taskObject.title = draft.title.trimmingCharacters(in: .whitespacesAndNewlines)
                taskObject.detailsText = draft.details.trimmingCharacters(in: .whitespacesAndNewlines)
                taskObject.isCompleted = draft.isCompleted

                try context.save()
                self.complete(.success(taskObject.toTaskItem()), completionBox: completionBox)
            } catch {
                self.complete(.failure(error), completionBox: completionBox)
            }
        }
    }

    public func updateCompletion(
        taskID: UUID,
        isCompleted: Bool,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        let completionBox = UncheckedSendableBox(completion)

        persistentContainer.performBackgroundTask { [weak self, completionBox] context in
            guard let self else { return }

            do {
                let task = try self.fetchManagedTask(id: taskID, in: context)
                task.isCompleted = isCompleted
                try context.save()
                self.complete(.success(()), completionBox: completionBox)
            } catch {
                self.complete(.failure(error), completionBox: completionBox)
            }
        }
    }

    public func deleteTask(
        id: UUID,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        let completionBox = UncheckedSendableBox(completion)

        persistentContainer.performBackgroundTask { [weak self, completionBox] context in
            guard let self else { return }

            do {
                let task = try self.fetchManagedTask(id: id, in: context)
                context.delete(task)
                try context.save()
                self.complete(.success(()), completionBox: completionBox)
            } catch {
                self.complete(.failure(error), completionBox: completionBox)
            }
        }
    }

    public func hasAnyTasks(completion: @escaping (Result<Bool, Error>) -> Void) {
        let completionBox = UncheckedSendableBox(completion)

        persistentContainer.performBackgroundTask { [weak self, completionBox] context in
            guard let self else { return }

            do {
                let request = TaskManagedObject.fetchRequestForTasks()
                request.fetchLimit = 1
                let count = try context.count(for: request)
                self.complete(.success(count > 0), completionBox: completionBox)
            } catch {
                self.complete(.failure(error), completionBox: completionBox)
            }
        }
    }

    public func replaceAll(
        with tasks: [TaskItem],
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        let completionBox = UncheckedSendableBox(completion)

        persistentContainer.performBackgroundTask { [weak self, completionBox] context in
            guard let self else { return }

            do {
                let request = TaskManagedObject.fetchRequestForTasks()
                let existingTasks = try context.fetch(request)
                existingTasks.forEach(context.delete(_:))

                for task in tasks {
                    let object = TaskManagedObject(context: context)
                    object.id = task.id
                    object.remoteID = task.remoteID.map { NSNumber(value: $0) }
                    object.title = task.title
                    object.detailsText = task.details
                    object.createdAt = task.createdAt
                    object.isCompleted = task.isCompleted
                }

                try context.save()
                self.complete(.success(()), completionBox: completionBox)
            } catch {
                self.complete(.failure(error), completionBox: completionBox)
            }
        }
    }

    private func fetchManagedTask(id: UUID, in context: NSManagedObjectContext) throws -> TaskManagedObject {
        let request = TaskManagedObject.fetchRequestForTasks()
        request.fetchLimit = 1
        request.predicate = NSPredicate(format: "id == %@", id as NSUUID)

        guard let task = try context.fetch(request).first else {
            throw TaskRepositoryError.taskNotFound
        }

        return task
    }

    private func normalized(_ query: String?) -> String? {
        guard let trimmed = query?.trimmingCharacters(in: .whitespacesAndNewlines), !trimmed.isEmpty else {
            return nil
        }

        return trimmed
    }

    private func complete<T>(
        _ result: Result<T, Error>,
        completionBox: UncheckedSendableBox<(Result<T, Error>) -> Void>
    ) {
        let resultBox = UncheckedSendableBox(result)

        callbackQueue.async { [completionBox, resultBox] in
            completionBox.value(resultBox.value)
        }
    }
}
