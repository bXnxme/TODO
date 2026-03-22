import Foundation

public enum TaskRepositoryError: LocalizedError {
    case taskNotFound

    public var errorDescription: String? {
        switch self {
        case .taskNotFound:
            return "Задача не найдена."
        }
    }
}

public protocol TaskRepository {
    func fetchTasks(
        matching query: String?,
        completion: @escaping (Result<[TaskItem], Error>) -> Void
    )
    func fetchTask(
        id: UUID,
        completion: @escaping (Result<TaskItem, Error>) -> Void
    )
    func saveTask(
        _ draft: TaskDraft,
        taskID: UUID?,
        completion: @escaping (Result<TaskItem, Error>) -> Void
    )
    func updateCompletion(
        taskID: UUID,
        isCompleted: Bool,
        completion: @escaping (Result<Void, Error>) -> Void
    )
    func deleteTask(
        id: UUID,
        completion: @escaping (Result<Void, Error>) -> Void
    )
    func hasAnyTasks(completion: @escaping (Result<Bool, Error>) -> Void)
    func replaceAll(
        with tasks: [TaskItem],
        completion: @escaping (Result<Void, Error>) -> Void
    )
}

