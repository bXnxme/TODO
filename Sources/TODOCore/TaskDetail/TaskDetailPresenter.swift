import Foundation

@MainActor
public final class TaskDetailPresenter: TaskDetailPresenterInput {
    private weak var view: TaskDetailView?
    private let interactor: TaskDetailInteractorInput
    private let router: TaskDetailRouterInput
    private let dateFormatter: TaskDateFormatting
    private let nowProvider: () -> Date

    private var task: TaskItem?
    private var completionRevertValue: Bool?

    public init(
        view: TaskDetailView,
        interactor: TaskDetailInteractorInput,
        router: TaskDetailRouterInput,
        dateFormatter: TaskDateFormatting,
        nowProvider: @escaping () -> Date = Date.init
    ) {
        self.view = view
        self.interactor = interactor
        self.router = router
        self.dateFormatter = dateFormatter
        self.nowProvider = nowProvider
    }

    public func viewDidLoad() {
        interactor.loadTask()
    }

    public func didTapSave(title: String, details: String, isCompleted: Bool) {
        let normalizedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalizedTitle.isEmpty else {
            view?.displayError(message: "Введите название задачи.")
            return
        }

        let normalizedDetails = details.trimmingCharacters(in: .whitespacesAndNewlines)
        interactor.saveTask(title: normalizedTitle, details: normalizedDetails, isCompleted: isCompleted)
    }

    public func didChangeCompletion(isCompleted: Bool) {
        guard let task, task.isCompleted != isCompleted else { return }

        completionRevertValue = task.isCompleted
        self.task?.isCompleted = isCompleted
        interactor.updateCompletion(isCompleted: isCompleted)
    }

    private func makeViewModel(for task: TaskItem?) -> TaskDetailViewModel {
        let createdAt = task?.createdAt ?? nowProvider()
        return TaskDetailViewModel(
            screenTitle: task == nil ? "Новая задача" : "Редактирование",
            saveButtonTitle: "Сохранить",
            title: task?.title ?? "",
            details: task?.details ?? "",
            createdAtText: "Создана \(dateFormatter.string(from: createdAt))",
            isCompleted: task?.isCompleted ?? false,
            isEditing: task != nil
        )
    }

    private func errorMessage(for error: Error) -> String {
        let message = error.localizedDescription.trimmingCharacters(in: .whitespacesAndNewlines)
        return message.isEmpty ? "Не удалось сохранить задачу." : message
    }
}

extension TaskDetailPresenter: TaskDetailInteractorOutput {
    public func didLoadTask(_ task: TaskItem?) {
        self.task = task
        view?.display(viewModel: makeViewModel(for: task))
    }

    public func didSaveTask(_ task: TaskItem) {
        self.task = task
        router.close(afterSave: true)
    }

    public func didUpdateCompletion(_ isCompleted: Bool) {
        task?.isCompleted = isCompleted
        completionRevertValue = nil
        router.notifyTaskDidChange()
    }

    public func didChangeSaving(_ isSaving: Bool) {
        view?.displaySaving(isSaving)
    }

    public func didReceiveError(_ error: Error) {
        if let completionRevertValue {
            task?.isCompleted = completionRevertValue
            self.completionRevertValue = nil
            view?.display(viewModel: makeViewModel(for: task))
        }

        view?.displayError(message: errorMessage(for: error))
    }
}
