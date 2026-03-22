import XCTest
@testable import TODOCore

final class TaskListInteractorTests: XCTestCase {
    @MainActor
    func testDeleteTaskDoesNotEmitLoadingStateAndDoesNotReloadOnSuccess() async {
        let repository = RepositorySpy()
        let output = OutputSpy()
        let interactor = TaskListInteractor(repository: repository, initialLoader: InitialLoaderSpy())
        interactor.output = output
        let taskID = UUID()

        interactor.deleteTask(id: taskID)

        XCTAssertEqual(repository.deletedTaskID, taskID)
        XCTAssertTrue(output.loadingStates.isEmpty)

        repository.deleteCompletion?(.success(()))
        await Task.yield()

        XCTAssertTrue(output.loadingStates.isEmpty)
        XCTAssertTrue(output.loadedTasks.isEmpty)
        XCTAssertNil(output.displayedError)
    }

    @MainActor
    func testDeleteTaskReportsErrorAndReloadsTasksWithoutLoadingIndicator() async {
        let repository = RepositorySpy()
        let output = OutputSpy()
        let interactor = TaskListInteractor(repository: repository, initialLoader: InitialLoaderSpy())
        interactor.output = output
        let loadedTasksExpectation = expectation(description: "Tasks reloaded after failed deletion")
        output.didLoadTasksExpectation = loadedTasksExpectation
        let restoredTask = TaskItem(
            id: UUID(),
            remoteID: nil,
            title: "Restored",
            details: "",
            createdAt: Date(),
            isCompleted: false
        )
        repository.fetchResult = .success([restoredTask])

        interactor.deleteTask(id: UUID())
        repository.deleteCompletion?(.failure(RepositoryError.failedDelete))
        await fulfillment(of: [loadedTasksExpectation], timeout: 1)

        XCTAssertTrue(output.loadingStates.isEmpty)
        XCTAssertEqual(output.displayedError as? RepositoryError, .failedDelete)
        XCTAssertEqual(output.loadedTasks, [restoredTask])
    }
}

private enum RepositoryError: Error {
    case failedDelete
}

@MainActor
private final class OutputSpy: TaskListInteractorOutput {
    var loadedTasks: [TaskItem] = []
    var loadingStates: [Bool] = []
    var displayedError: Error?
    var didLoadTasksExpectation: XCTestExpectation?

    func didLoadTasks(_ tasks: [TaskItem]) {
        loadedTasks = tasks
        didLoadTasksExpectation?.fulfill()
    }

    func didChangeLoading(_ isLoading: Bool) {
        loadingStates.append(isLoading)
    }

    func didReceiveError(_ error: Error) {
        displayedError = error
    }
}

private final class RepositorySpy: TaskRepository {
    var fetchResult: Result<[TaskItem], Error> = .success([])
    var deletedTaskID: UUID?
    var deleteCompletion: ((Result<Void, Error>) -> Void)?

    func fetchTasks(
        matching query: String?,
        completion: @escaping (Result<[TaskItem], Error>) -> Void
    ) {
        completion(fetchResult)
    }

    func fetchTask(
        id: UUID,
        completion: @escaping (Result<TaskItem, Error>) -> Void
    ) {
        fatalError("Not needed in tests")
    }

    func saveTask(
        _ draft: TaskDraft,
        taskID: UUID?,
        completion: @escaping (Result<TaskItem, Error>) -> Void
    ) {
        fatalError("Not needed in tests")
    }

    func updateCompletion(
        taskID: UUID,
        isCompleted: Bool,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        fatalError("Not needed in tests")
    }

    func deleteTask(
        id: UUID,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        deletedTaskID = id
        deleteCompletion = completion
    }

    func hasAnyTasks(completion: @escaping (Result<Bool, Error>) -> Void) {
        fatalError("Not needed in tests")
    }

    func replaceAll(
        with tasks: [TaskItem],
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        fatalError("Not needed in tests")
    }
}

private struct InitialLoaderSpy: InitialTaskLoading {
    func loadIfNeeded(completion: @escaping (Result<Bool, Error>) -> Void) {
        completion(.success(false))
    }
}
