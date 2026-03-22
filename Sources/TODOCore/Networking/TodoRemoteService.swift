import Foundation

public enum TodoRemoteServiceError: LocalizedError {
    case invalidEndpoint
    case invalidResponse
    case missingData

    public var errorDescription: String? {
        switch self {
        case .invalidEndpoint:
            return "Некорректный адрес API."
        case .invalidResponse:
            return "API вернуло некорректный ответ."
        case .missingData:
            return "API не вернуло данные."
        }
    }
}

public protocol TodoRemoteService {
    func fetchTodos(completion: @escaping (Result<[TaskItem], Error>) -> Void)
}

public final class DummyJSONTodoService: TodoRemoteService, @unchecked Sendable {
    private let session: URLSession
    private let mapper: DummyJSONTodoMapper
    private let callbackQueue: DispatchQueue
    private let decodingQueue: DispatchQueue
    private let endpoint: URL

    public init(
        endpoint: URL = URL(string: "https://dummyjson.com/todos")!,
        session: URLSession = .shared,
        mapper: DummyJSONTodoMapper = DummyJSONTodoMapper(),
        callbackQueue: DispatchQueue = .main,
        decodingQueue: DispatchQueue = DispatchQueue(label: "com.polzovatel.todo.remote-decoding", qos: .userInitiated)
    ) {
        self.endpoint = endpoint
        self.session = session
        self.mapper = mapper
        self.callbackQueue = callbackQueue
        self.decodingQueue = decodingQueue
    }

    public func fetchTodos(completion: @escaping (Result<[TaskItem], Error>) -> Void) {
        var request = URLRequest(url: endpoint)
        request.timeoutInterval = 30
        let completionBox = UncheckedSendableBox(completion)

        session.dataTask(with: request) { [weak self, completionBox] data, response, error in
            guard let self else { return }

            if let error {
                self.complete(.failure(error), completionBox: completionBox)
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
                self.complete(.failure(TodoRemoteServiceError.invalidResponse), completionBox: completionBox)
                return
            }

            guard let data else {
                self.complete(.failure(TodoRemoteServiceError.missingData), completionBox: completionBox)
                return
            }

            self.decodingQueue.async { [weak self, completionBox] in
                guard let self else { return }

                do {
                    let tasks = try self.mapper.map(data: data)
                    self.complete(.success(tasks), completionBox: completionBox)
                } catch {
                    self.complete(.failure(error), completionBox: completionBox)
                }
            }
        }.resume()
    }

    private func complete(
        _ result: Result<[TaskItem], Error>,
        completionBox: UncheckedSendableBox<(Result<[TaskItem], Error>) -> Void>
    ) {
        let resultBox = UncheckedSendableBox(result)

        callbackQueue.async { [completionBox, resultBox] in
            completionBox.value(resultBox.value)
        }
    }
}
