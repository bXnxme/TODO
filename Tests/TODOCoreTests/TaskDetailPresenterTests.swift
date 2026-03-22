import XCTest
@testable import TODOCore

final class TaskDetailPresenterTests: XCTestCase {
    @MainActor
    func testViewDidLoadRequestsTaskFromInteractor() {
        let view = ViewSpy()
        let interactor = InteractorSpy()
        let router = RouterSpy()
        let presenter = TaskDetailPresenter(
            view: view,
            interactor: interactor,
            router: router,
            dateFormatter: FormatterSpy()
        )

        presenter.viewDidLoad()

        XCTAssertEqual(interactor.loadTaskCallCount, 1)
    }

    @MainActor
    func testDidTapSaveShowsValidationErrorForEmptyTitle() {
        let view = ViewSpy()
        let interactor = InteractorSpy()
        let router = RouterSpy()
        let presenter = TaskDetailPresenter(
            view: view,
            interactor: interactor,
            router: router,
            dateFormatter: FormatterSpy()
        )

        presenter.didTapSave(title: "   ", details: "details", isCompleted: false)

        XCTAssertEqual(view.displayedError, "Введите название задачи.")
        XCTAssertEqual(interactor.savedDraft?.title, nil)
    }

    @MainActor
    func testDidLoadTaskBuildsEditingViewModel() {
        let view = ViewSpy()
        let interactor = InteractorSpy()
        let router = RouterSpy()
        let presenter = TaskDetailPresenter(
            view: view,
            interactor: interactor,
            router: router,
            dateFormatter: FormatterSpy()
        )
        let task = TaskItem(
            id: UUID(),
            remoteID: nil,
            title: "Workout",
            details: "Morning run",
            createdAt: Date(),
            isCompleted: true
        )

        presenter.didLoadTask(task)

        XCTAssertEqual(
            view.displayedViewModel,
            TaskDetailViewModel(
                screenTitle: "Редактирование",
                saveButtonTitle: "Сохранить",
                title: "Workout",
                details: "Morning run",
                createdAtText: "Создана fixed-date",
                isCompleted: true,
                isEditing: true
            )
        )
    }

    @MainActor
    func testDidSaveTaskRequestsRouterClose() {
        let view = ViewSpy()
        let interactor = InteractorSpy()
        let router = RouterSpy()
        let presenter = TaskDetailPresenter(
            view: view,
            interactor: interactor,
            router: router,
            dateFormatter: FormatterSpy()
        )

        presenter.didSaveTask(
            TaskItem(
                id: UUID(),
                remoteID: nil,
                title: "Saved",
                details: "",
                createdAt: Date(),
                isCompleted: false
            )
        )

        XCTAssertTrue(router.didCloseAfterSave)
    }

    @MainActor
    func testDidChangeCompletionForLoadedTaskRequestsInteractorUpdate() {
        let view = ViewSpy()
        let interactor = InteractorSpy()
        let router = RouterSpy()
        let presenter = TaskDetailPresenter(
            view: view,
            interactor: interactor,
            router: router,
            dateFormatter: FormatterSpy()
        )
        let task = TaskItem(
            id: UUID(),
            remoteID: nil,
            title: "Saved",
            details: "",
            createdAt: Date(),
            isCompleted: false
        )

        presenter.didLoadTask(task)
        presenter.didChangeCompletion(isCompleted: true)

        XCTAssertEqual(interactor.updatedCompletion, true)
    }

    @MainActor
    func testDidUpdateCompletionNotifiesRouterAboutChanges() {
        let view = ViewSpy()
        let interactor = InteractorSpy()
        let router = RouterSpy()
        let presenter = TaskDetailPresenter(
            view: view,
            interactor: interactor,
            router: router,
            dateFormatter: FormatterSpy()
        )
        let task = TaskItem(
            id: UUID(),
            remoteID: nil,
            title: "Saved",
            details: "",
            createdAt: Date(),
            isCompleted: false
        )

        presenter.didLoadTask(task)
        presenter.didChangeCompletion(isCompleted: true)
        presenter.didUpdateCompletion(true)

        XCTAssertTrue(router.didNotifyTaskChanged)
    }

    @MainActor
    private final class ViewSpy: TaskDetailView {
        var displayedViewModel: TaskDetailViewModel?
        var savingStates: [Bool] = []
        var displayedError: String?

        func display(viewModel: TaskDetailViewModel) {
            displayedViewModel = viewModel
        }

        func displaySaving(_ isSaving: Bool) {
            savingStates.append(isSaving)
        }

        func displayError(message: String) {
            displayedError = message
        }
    }

    @MainActor
    private final class InteractorSpy: TaskDetailInteractorInput {
        var loadTaskCallCount = 0
        var savedDraft: (title: String, details: String, isCompleted: Bool)?
        var updatedCompletion: Bool?

        func loadTask() {
            loadTaskCallCount += 1
        }

        func saveTask(title: String, details: String, isCompleted: Bool) {
            savedDraft = (title, details, isCompleted)
        }

        func updateCompletion(isCompleted: Bool) {
            updatedCompletion = isCompleted
        }
    }

    @MainActor
    private final class RouterSpy: TaskDetailRouterInput {
        var didCloseAfterSave = false
        var didNotifyTaskChanged = false

        func close(afterSave: Bool) {
            didCloseAfterSave = afterSave
        }

        func notifyTaskDidChange() {
            didNotifyTaskChanged = true
        }
    }

    private struct FormatterSpy: TaskDateFormatting {
        func string(from date: Date) -> String { "fixed-date" }
    }
}
