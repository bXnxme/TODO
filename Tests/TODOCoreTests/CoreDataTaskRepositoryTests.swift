import XCTest
@testable import TODOCore

@MainActor
final class CoreDataTaskRepositoryTests: XCTestCase {
    func testSaveAndFetchTasksPersistsDataInMemoryStore() throws {
        let stack = try CoreDataStack(inMemory: true)
        let repository = CoreDataTaskRepository(coreDataStack: stack)
        let saveExpectation = expectation(description: "save")
        var savedTask: TaskItem?

        repository.saveTask(
            TaskDraft(title: "Read book", details: "10 pages", isCompleted: false),
            taskID: nil
        ) { result in
            savedTask = try? result.get()
            saveExpectation.fulfill()
        }

        waitForExpectations(timeout: 1)
        XCTAssertEqual(savedTask?.title, "Read book")

        let fetchExpectation = expectation(description: "fetch")
        var fetchedTasks: [TaskItem] = []

        repository.fetchTasks(matching: "book") { result in
            fetchedTasks = (try? result.get()) ?? []
            fetchExpectation.fulfill()
        }

        waitForExpectations(timeout: 1)
        XCTAssertEqual(fetchedTasks.count, 1)
        XCTAssertEqual(fetchedTasks.first?.details, "10 pages")
    }

    func testDeleteRemovesPersistedTask() throws {
        let stack = try CoreDataStack(inMemory: true)
        let repository = CoreDataTaskRepository(coreDataStack: stack)
        let saveExpectation = expectation(description: "save")
        var taskID: UUID?

        repository.saveTask(
            TaskDraft(title: "Delete me", details: "", isCompleted: false),
            taskID: nil
        ) { result in
            taskID = try? result.get().id
            saveExpectation.fulfill()
        }

        waitForExpectations(timeout: 1)
        XCTAssertNotNil(taskID)

        let deleteExpectation = expectation(description: "delete")
        repository.deleteTask(id: taskID!) { _ in
            deleteExpectation.fulfill()
        }
        waitForExpectations(timeout: 1)

        let fetchExpectation = expectation(description: "fetch")
        var fetchedTasks: [TaskItem] = []
        repository.fetchTasks(matching: nil) { result in
            fetchedTasks = (try? result.get()) ?? []
            fetchExpectation.fulfill()
        }

        waitForExpectations(timeout: 1)
        XCTAssertTrue(fetchedTasks.isEmpty)
    }
}
