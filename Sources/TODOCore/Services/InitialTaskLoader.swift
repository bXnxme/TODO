import Foundation

public protocol InitialTaskLoading {
    func loadIfNeeded(completion: @escaping (Result<Bool, Error>) -> Void)
}

public final class InitialTaskLoader: InitialTaskLoading {
    private let remoteService: TodoRemoteService
    private let repository: TaskRepository
    private let settings: AppSettingsStorage

    public init(
        remoteService: TodoRemoteService,
        repository: TaskRepository,
        settings: AppSettingsStorage
    ) {
        self.remoteService = remoteService
        self.repository = repository
        self.settings = settings
    }

    public func loadIfNeeded(completion: @escaping (Result<Bool, Error>) -> Void) {
        if settings.hasLoadedInitialTasks {
            completion(.success(false))
            return
        }

        repository.hasAnyTasks { [weak self] result in
            guard let self else { return }

            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let hasTasks):
                if hasTasks {
                    self.settings.hasLoadedInitialTasks = true
                    completion(.success(false))
                    return
                }

                self.remoteService.fetchTodos { remoteResult in
                    switch remoteResult {
                    case .failure(let error):
                        completion(.failure(error))
                    case .success(let tasks):
                        self.repository.replaceAll(with: tasks) { saveResult in
                            switch saveResult {
                            case .failure(let error):
                                completion(.failure(error))
                            case .success:
                                self.settings.hasLoadedInitialTasks = true
                                completion(.success(true))
                            }
                        }
                    }
                }
            }
        }
    }
}

