import Foundation

@MainActor
public final class TaskListInteractor: TaskListInteractorInput {
    public weak var output: TaskListInteractorOutput?

    private let repository: TaskRepository
    private let initialLoader: InitialTaskLoading
    private var currentQuery: String?

    public init(repository: TaskRepository, initialLoader: InitialTaskLoading) {
        self.repository = repository
        self.initialLoader = initialLoader
    }

    public func loadInitialData() {
        output?.didChangeLoading(true)
        initialLoader.loadIfNeeded { [weak self] result in
            Task { @MainActor in
                guard let self else { return }

                if case .failure(let error) = result {
                    self.output?.didReceiveError(error)
                }

                self.fetchTasks(showLoading: false, hideLoadingOnCompletion: true)
            }
        }
    }

    public func reloadTasks() {
        fetchTasks(showLoading: true)
    }

    public func searchTasks(matching query: String?) {
        currentQuery = normalized(query)
        fetchTasks(showLoading: true)
    }

    public func deleteTask(id: UUID) {
        repository.deleteTask(id: id) { [weak self] result in
            Task { @MainActor in
                guard let self else { return }

                switch result {
                case .failure(let error):
                    self.output?.didReceiveError(error)
                    self.fetchTasks(showLoading: false, hideLoadingOnCompletion: false)
                case .success:
                    break
                }
            }
        }
    }

    public func updateCompletion(taskID: UUID, isCompleted: Bool) {
        repository.updateCompletion(taskID: taskID, isCompleted: isCompleted) { [weak self] result in
            Task { @MainActor in
                guard let self else { return }

                switch result {
                case .failure(let error):
                    self.output?.didReceiveError(error)
                    self.fetchTasks(showLoading: false, hideLoadingOnCompletion: false)
                case .success:
                    break
                }
            }
        }
    }

    private func fetchTasks(showLoading: Bool, hideLoadingOnCompletion: Bool = true) {
        if showLoading {
            output?.didChangeLoading(true)
        }

        repository.fetchTasks(matching: currentQuery) { [weak self] result in
            Task { @MainActor in
                guard let self else { return }

                if hideLoadingOnCompletion {
                    self.output?.didChangeLoading(false)
                }
                switch result {
                case .failure(let error):
                    self.output?.didReceiveError(error)
                case .success(let tasks):
                    self.output?.didLoadTasks(tasks)
                }
            }
        }
    }

    private func normalized(_ query: String?) -> String? {
        guard let trimmed = query?.trimmingCharacters(in: .whitespacesAndNewlines), !trimmed.isEmpty else {
            return nil
        }

        return trimmed
    }
}
