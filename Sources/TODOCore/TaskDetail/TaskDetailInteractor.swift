import Foundation

@MainActor
public final class TaskDetailInteractor: TaskDetailInteractorInput {
    public weak var output: TaskDetailInteractorOutput?

    private let taskID: UUID?
    private let repository: TaskRepository

    public init(taskID: UUID?, repository: TaskRepository) {
        self.taskID = taskID
        self.repository = repository
    }

    public func loadTask() {
        guard let taskID else {
            output?.didLoadTask(nil)
            return
        }

        output?.didChangeSaving(true)
        repository.fetchTask(id: taskID) { [weak self] result in
            Task { @MainActor in
                guard let self else { return }

                self.output?.didChangeSaving(false)
                switch result {
                case .failure(let error):
                    self.output?.didReceiveError(error)
                case .success(let task):
                    self.output?.didLoadTask(task)
                }
            }
        }
    }

    public func saveTask(title: String, details: String, isCompleted: Bool) {
        output?.didChangeSaving(true)

        let draft = TaskDraft(title: title, details: details, isCompleted: isCompleted)
        repository.saveTask(draft, taskID: taskID) { [weak self] result in
            Task { @MainActor in
                guard let self else { return }

                self.output?.didChangeSaving(false)
                switch result {
                case .failure(let error):
                    self.output?.didReceiveError(error)
                case .success(let task):
                    self.output?.didSaveTask(task)
                }
            }
        }
    }

    public func updateCompletion(isCompleted: Bool) {
        guard let taskID else { return }

        repository.updateCompletion(taskID: taskID, isCompleted: isCompleted) { [weak self] result in
            Task { @MainActor in
                guard let self else { return }

                switch result {
                case .failure(let error):
                    self.output?.didReceiveError(error)
                case .success:
                    self.output?.didUpdateCompletion(isCompleted)
                }
            }
        }
    }
}
