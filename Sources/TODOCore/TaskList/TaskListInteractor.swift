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

                self.fetchTasks(showLoading: false)
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
        output?.didChangeLoading(true)
        repository.deleteTask(id: id) { [weak self] result in
            Task { @MainActor in
                guard let self else { return }

                switch result {
                case .failure(let error):
                    self.output?.didChangeLoading(false)
                    self.output?.didReceiveError(error)
                case .success:
                    self.fetchTasks(showLoading: false)
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
                    self.fetchTasks(showLoading: false)
                case .success:
                    break
                }
            }
        }
    }

    private func fetchTasks(showLoading: Bool) {
        if showLoading {
            output?.didChangeLoading(true)
        }

        repository.fetchTasks(matching: currentQuery) { [weak self] result in
            Task { @MainActor in
                guard let self else { return }

                self.output?.didChangeLoading(false)
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
