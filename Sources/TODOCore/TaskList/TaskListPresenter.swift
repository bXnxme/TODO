import Foundation

@MainActor
public final class TaskListPresenter: TaskListPresenterInput {
    private weak var view: TaskListView?
    private let interactor: TaskListInteractorInput
    private let router: TaskListRouterInput
    private let dateFormatter: TaskDateFormatting
    private let searchQueue: DispatchQueue
    private let searchDelay: TimeInterval

    private var tasks: [TaskItem] = []
    private var pendingSearchWorkItem: DispatchWorkItem?

    public init(
        view: TaskListView,
        interactor: TaskListInteractorInput,
        router: TaskListRouterInput,
        dateFormatter: TaskDateFormatting,
        searchQueue: DispatchQueue = .main,
        searchDelay: TimeInterval = 0.3
    ) {
        self.view = view
        self.interactor = interactor
        self.router = router
        self.dateFormatter = dateFormatter
        self.searchQueue = searchQueue
        self.searchDelay = searchDelay
    }

    public func viewDidLoad() {
        interactor.loadInitialData()
    }

    public func didPullToRefresh() {
        interactor.reloadTasks()
    }

    public func didTapAddTask() {
        router.showTaskDetail(taskID: nil) { [weak self] in
            self?.interactor.reloadTasks()
        }
    }

    public func didSelectTask(at index: Int) {
        guard tasks.indices.contains(index) else { return }

        let taskID = tasks[index].id
        router.showTaskDetail(taskID: taskID) { [weak self] in
            self?.interactor.reloadTasks()
        }
    }

    public func didDeleteTask(at index: Int) {
        guard tasks.indices.contains(index) else { return }
        interactor.deleteTask(id: tasks[index].id)
    }

    public func didChangeCompletion(at index: Int, isCompleted: Bool) {
        guard tasks.indices.contains(index) else { return }

        tasks[index].isCompleted = isCompleted
        view?.display(tasks: makeViewModels(from: tasks))
        interactor.updateCompletion(taskID: tasks[index].id, isCompleted: isCompleted)
    }

    public func didSearch(query: String?) {
        pendingSearchWorkItem?.cancel()

        let workItem = DispatchWorkItem { [weak self] in
            self?.interactor.searchTasks(matching: query)
        }
        pendingSearchWorkItem = workItem

        if searchDelay <= 0 {
            workItem.perform()
        } else {
            searchQueue.asyncAfter(deadline: .now() + searchDelay, execute: workItem)
        }
    }

    private func makeViewModels(from tasks: [TaskItem]) -> [TaskListItemViewModel] {
        tasks.map { task in
            let hasDetails = !task.details.isEmpty
            return TaskListItemViewModel(
                id: task.id,
                title: task.title,
                details: hasDetails ? task.details : "Без описания",
                hasDetails: hasDetails,
                createdAtText: "Создана \(dateFormatter.string(from: task.createdAt))",
                statusText: task.isCompleted ? "Выполнена" : "Не выполнена",
                isCompleted: task.isCompleted
            )
        }
    }

    private func errorMessage(for error: Error) -> String {
        let message = error.localizedDescription.trimmingCharacters(in: .whitespacesAndNewlines)
        return message.isEmpty ? "Не удалось выполнить операцию." : message
    }
}

extension TaskListPresenter: TaskListInteractorOutput {
    public func didLoadTasks(_ tasks: [TaskItem]) {
        self.tasks = tasks
        view?.display(tasks: makeViewModels(from: tasks))
    }

    public func didChangeLoading(_ isLoading: Bool) {
        view?.displayLoading(isLoading)
    }

    public func didReceiveError(_ error: Error) {
        view?.displayError(message: errorMessage(for: error))
    }
}
