import Foundation

public struct TaskDetailViewModel: Equatable {
    public let screenTitle: String
    public let saveButtonTitle: String
    public let title: String
    public let details: String
    public let createdAtText: String
    public let isCompleted: Bool
    public let isEditing: Bool

    public init(
        screenTitle: String,
        saveButtonTitle: String,
        title: String,
        details: String,
        createdAtText: String,
        isCompleted: Bool,
        isEditing: Bool
    ) {
        self.screenTitle = screenTitle
        self.saveButtonTitle = saveButtonTitle
        self.title = title
        self.details = details
        self.createdAtText = createdAtText
        self.isCompleted = isCompleted
        self.isEditing = isEditing
    }
}

@MainActor
public protocol TaskDetailView: AnyObject {
    func display(viewModel: TaskDetailViewModel)
    func displaySaving(_ isSaving: Bool)
    func displayError(message: String)
}

@MainActor
public protocol TaskDetailPresenterInput: AnyObject {
    func viewDidLoad()
    func didTapSave(title: String, details: String, isCompleted: Bool)
    func didChangeCompletion(isCompleted: Bool)
}

@MainActor
public protocol TaskDetailInteractorInput: AnyObject {
    func loadTask()
    func saveTask(title: String, details: String, isCompleted: Bool)
    func updateCompletion(isCompleted: Bool)
}

@MainActor
public protocol TaskDetailInteractorOutput: AnyObject {
    func didLoadTask(_ task: TaskItem?)
    func didSaveTask(_ task: TaskItem)
    func didUpdateCompletion(_ isCompleted: Bool)
    func didChangeSaving(_ isSaving: Bool)
    func didReceiveError(_ error: Error)
}

@MainActor
public protocol TaskDetailRouterInput: AnyObject {
    func close(afterSave: Bool)
    func notifyTaskDidChange()
}
