import XCTest
@testable import TODOCore

@MainActor
final class InitialTaskLoaderTests: XCTestCase {
    func testLoadIfNeededImportsRemoteTasksOnFirstLaunch() {
        let repository = RepositorySpy()
        let remoteService = RemoteServiceSpy()
        let settings = SettingsSpy()
        let expectedTasks = [
            TaskItem(
                id: UUID(),
                remoteID: 1,
                title: "Remote",
                details: "",
                createdAt: Date(),
                isCompleted: false
            )
        ]
        remoteService.tasksToReturn = expectedTasks

        let loader = InitialTaskLoader(
            remoteService: remoteService,
            repository: repository,
            settings: settings
        )

        let expectation = expectation(description: "load completed")
        var result: Result<Bool, Error>?

        loader.loadIfNeeded {
            result = $0
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1)

        XCTAssertEqual(try? result?.get(), true)
        XCTAssertEqual(remoteService.fetchTodosCallCount, 1)
        XCTAssertEqual(repository.replacedTasks, expectedTasks)
        XCTAssertTrue(settings.hasLoadedInitialTasks)
    }

    func testLoadIfNeededSkipsRemoteWhenAlreadyLoaded() {
        let repository = RepositorySpy()
        let remoteService = RemoteServiceSpy()
        let settings = SettingsSpy()
        settings.hasLoadedInitialTasks = true

        let loader = InitialTaskLoader(
            remoteService: remoteService,
            repository: repository,
            settings: settings
        )

        let expectation = expectation(description: "load completed")
        var result: Result<Bool, Error>?

        loader.loadIfNeeded {
            result = $0
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1)

        XCTAssertEqual(try? result?.get(), false)
        XCTAssertEqual(remoteService.fetchTodosCallCount, 0)
        XCTAssertNil(repository.replacedTasks)
    }

    private final class RepositorySpy: TaskRepository {
        var replacedTasks: [TaskItem]?
        var hasAnyTasksResult = false

        func fetchTasks(matching query: String?, completion: @escaping (Result<[TaskItem], Error>) -> Void) {
            completion(.success([]))
        }

        func fetchTask(id: UUID, completion: @escaping (Result<TaskItem, Error>) -> Void) {
            fatalError("Not needed")
        }

        func saveTask(_ draft: TaskDraft, taskID: UUID?, completion: @escaping (Result<TaskItem, Error>) -> Void) {
            fatalError("Not needed")
        }

        func updateCompletion(taskID: UUID, isCompleted: Bool, completion: @escaping (Result<Void, Error>) -> Void) {
            fatalError("Not needed")
        }

        func deleteTask(id: UUID, completion: @escaping (Result<Void, Error>) -> Void) {
            fatalError("Not needed")
        }

        func hasAnyTasks(completion: @escaping (Result<Bool, Error>) -> Void) {
            completion(.success(hasAnyTasksResult))
        }

        func replaceAll(with tasks: [TaskItem], completion: @escaping (Result<Void, Error>) -> Void) {
            replacedTasks = tasks
            completion(.success(()))
        }
    }

    private final class RemoteServiceSpy: TodoRemoteService {
        var fetchTodosCallCount = 0
        var tasksToReturn: [TaskItem] = []

        func fetchTodos(completion: @escaping (Result<[TaskItem], Error>) -> Void) {
            fetchTodosCallCount += 1
            completion(.success(tasksToReturn))
        }
    }

    private final class SettingsSpy: AppSettingsStorage {
        var hasLoadedInitialTasks = false
    }
}
