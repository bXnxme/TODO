import XCTest
@testable import TODOCore

final class TaskListPresenterTests: XCTestCase {
    @MainActor
    func testDidLoadTasksMapsItemsForView() {
        let view = ViewSpy()
        let interactor = InteractorSpy()
        let router = RouterSpy()
        let presenter = TaskListPresenter(
            view: view,
            interactor: interactor,
            router: router,
            dateFormatter: FormatterSpy(),
            searchDelay: 0
        )

        let task = TaskItem(
            id: UUID(),
            remoteID: nil,
            title: "Pay bills",
            details: "",
            createdAt: Date(timeIntervalSince1970: 100),
            isCompleted: false
        )

        presenter.didLoadTasks([task])

        XCTAssertEqual(
            view.displayedTasks,
            [
                TaskListItemViewModel(
                    id: task.id,
                    title: "Pay bills",
                    details: "Без описания",
                    hasDetails: false,
                    createdAtText: "Создана fixed-date",
                    statusText: "Не выполнена",
                    isCompleted: false
                )
            ]
        )
    }

    @MainActor
    func testDidTapAddTaskRoutesToTaskCreation() {
        let view = ViewSpy()
        let interactor = InteractorSpy()
        let router = RouterSpy()
        let presenter = TaskListPresenter(
            view: view,
            interactor: interactor,
            router: router,
            dateFormatter: FormatterSpy(),
            searchDelay: 0
        )

        presenter.didTapAddTask()

        XCTAssertEqual(router.lastTaskID, nil)
    }

    @MainActor
    func testDidSearchForwardsQueryToInteractor() {
        let view = ViewSpy()
        let interactor = InteractorSpy()
        let router = RouterSpy()
        let presenter = TaskListPresenter(
            view: view,
            interactor: interactor,
            router: router,
            dateFormatter: FormatterSpy(),
            searchDelay: 0
        )

        presenter.didSearch(query: " milk ")

        XCTAssertEqual(interactor.lastSearchQuery, " milk ")
    }

    @MainActor
    func testDidChangeCompletionUsesCurrentTaskIdentifier() {
        let view = ViewSpy()
        let interactor = InteractorSpy()
        let router = RouterSpy()
        let presenter = TaskListPresenter(
            view: view,
            interactor: interactor,
            router: router,
            dateFormatter: FormatterSpy(),
            searchDelay: 0
        )
        let task = TaskItem(
            id: UUID(),
            remoteID: nil,
            title: "Call mom",
            details: "Today",
            createdAt: Date(),
            isCompleted: false
        )

        presenter.didLoadTasks([task])
        presenter.didChangeCompletion(at: 0, isCompleted: true)

        XCTAssertEqual(interactor.updatedCompletion?.taskID, task.id)
        XCTAssertEqual(interactor.updatedCompletion?.isCompleted, true)
    }

    @MainActor
    func testDidChangeCompletionUpdatesViewImmediatelyWithoutWaitingForReload() {
        let view = ViewSpy()
        let interactor = InteractorSpy()
        let router = RouterSpy()
        let presenter = TaskListPresenter(
            view: view,
            interactor: interactor,
            router: router,
            dateFormatter: FormatterSpy(),
            searchDelay: 0
        )
        let task = TaskItem(
            id: UUID(),
            remoteID: nil,
            title: "Call mom",
            details: "Today",
            createdAt: Date(),
            isCompleted: false
        )

        presenter.didLoadTasks([task])
        presenter.didChangeCompletion(at: 0, isCompleted: true)

        XCTAssertEqual(view.displayedTasks.first?.isCompleted, true)
        XCTAssertEqual(view.displayedTasks.first?.statusText, "Выполнена")
    }

    @MainActor
    func testDidDeleteTaskRemovesItemFromViewImmediatelyAndRequestsInteractorDeletion() {
        let view = ViewSpy()
        let interactor = InteractorSpy()
        let router = RouterSpy()
        let presenter = TaskListPresenter(
            view: view,
            interactor: interactor,
            router: router,
            dateFormatter: FormatterSpy(),
            searchDelay: 0
        )
        let firstTask = TaskItem(
            id: UUID(),
            remoteID: nil,
            title: "First",
            details: "",
            createdAt: Date(),
            isCompleted: false
        )
        let secondTask = TaskItem(
            id: UUID(),
            remoteID: nil,
            title: "Second",
            details: "",
            createdAt: Date(),
            isCompleted: false
        )

        presenter.didLoadTasks([firstTask, secondTask])
        presenter.didDeleteTask(at: 0)

        XCTAssertEqual(interactor.deletedTaskID, firstTask.id)
        XCTAssertEqual(view.deletedIndices, [0])
        XCTAssertEqual(view.displayedTasks.map(\.id), [secondTask.id])
    }

    @MainActor
    private final class ViewSpy: TaskListView {
        var displayedTasks: [TaskListItemViewModel] = []
        var deletedIndices: [Int] = []
        var loadingStates: [Bool] = []
        var displayedError: String?

        func display(tasks: [TaskListItemViewModel]) {
            displayedTasks = tasks
        }

        func deleteTask(at index: Int) {
            deletedIndices.append(index)
            guard displayedTasks.indices.contains(index) else { return }
            displayedTasks.remove(at: index)
        }

        func displayLoading(_ isLoading: Bool) {
            loadingStates.append(isLoading)
        }

        func displayError(message: String) {
            displayedError = message
        }
    }

    @MainActor
    private final class InteractorSpy: TaskListInteractorInput {
        var lastSearchQuery: String?
        var deletedTaskID: UUID?
        var updatedCompletion: (taskID: UUID, isCompleted: Bool)?

        func loadInitialData() {}
        func reloadTasks() {}

        func searchTasks(matching query: String?) {
            lastSearchQuery = query
        }

        func deleteTask(id: UUID) {
            deletedTaskID = id
        }

        func updateCompletion(taskID: UUID, isCompleted: Bool) {
            updatedCompletion = (taskID, isCompleted)
        }
    }

    @MainActor
    private final class RouterSpy: TaskListRouterInput {
        var lastTaskID: UUID?

        func showTaskDetail(taskID: UUID?, onFinish: @escaping () -> Void) {
            lastTaskID = taskID
        }
    }

    private struct FormatterSpy: TaskDateFormatting {
        func string(from date: Date) -> String { "fixed-date" }
    }
}
