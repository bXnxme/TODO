import Foundation

public struct TaskListItemViewModel: Equatable {
    public let id: UUID
    public let title: String
    public let details: String
    public let hasDetails: Bool
    public let createdAtText: String
    public let statusText: String
    public let isCompleted: Bool

    public init(
        id: UUID,
        title: String,
        details: String,
        hasDetails: Bool,
        createdAtText: String,
        statusText: String,
        isCompleted: Bool
    ) {
        self.id = id
        self.title = title
        self.details = details
        self.hasDetails = hasDetails
        self.createdAtText = createdAtText
        self.statusText = statusText
        self.isCompleted = isCompleted
    }
}

@MainActor
public protocol TaskListView: AnyObject {
    func display(tasks: [TaskListItemViewModel])
    func displayLoading(_ isLoading: Bool)
    func displayError(message: String)
}

@MainActor
public protocol TaskListPresenterInput: AnyObject {
    func viewDidLoad()
    func didPullToRefresh()
    func didTapAddTask()
    func didSelectTask(at index: Int)
    func didDeleteTask(at index: Int)
    func didChangeCompletion(at index: Int, isCompleted: Bool)
    func didSearch(query: String?)
}

@MainActor
public protocol TaskListInteractorInput: AnyObject {
    func loadInitialData()
    func reloadTasks()
    func searchTasks(matching query: String?)
    func deleteTask(id: UUID)
    func updateCompletion(taskID: UUID, isCompleted: Bool)
}

@MainActor
public protocol TaskListInteractorOutput: AnyObject {
    func didLoadTasks(_ tasks: [TaskItem])
    func didChangeLoading(_ isLoading: Bool)
    func didReceiveError(_ error: Error)
}

@MainActor
public protocol TaskListRouterInput: AnyObject {
    func showTaskDetail(taskID: UUID?, onFinish: @escaping () -> Void)
}
