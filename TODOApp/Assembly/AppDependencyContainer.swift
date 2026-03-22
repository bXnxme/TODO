import Foundation
import TODOCore

final class AppDependencyContainer {
    let repository: TaskRepository
    let initialLoader: InitialTaskLoading
    let dateFormatter: TaskDateFormatting

    init() {
        do {
            let coreDataStack = try CoreDataStack()
            repository = CoreDataTaskRepository(coreDataStack: coreDataStack)
            let remoteService = DummyJSONTodoService()
            let settings = UserDefaultsAppSettings()
            initialLoader = InitialTaskLoader(
                remoteService: remoteService,
                repository: repository,
                settings: settings
            )
            dateFormatter = TaskDateFormatter()
        } catch {
            fatalError("Failed to initialize app dependencies: \(error)")
        }
    }
}

