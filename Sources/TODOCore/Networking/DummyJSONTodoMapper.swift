import Foundation

public struct DummyJSONTodoEnvelope: Decodable, Equatable, Sendable {
    public let todos: [DummyJSONTodoDTO]

    public init(todos: [DummyJSONTodoDTO]) {
        self.todos = todos
    }
}

public struct DummyJSONTodoDTO: Decodable, Equatable, Sendable {
    public let id: Int
    public let todo: String
    public let completed: Bool
    public let userId: Int

    public init(id: Int, todo: String, completed: Bool, userId: Int) {
        self.id = id
        self.todo = todo
        self.completed = completed
        self.userId = userId
    }
}

public struct DummyJSONTodoMapper: Sendable {
    public typealias UUIDFactory = @Sendable (Int) -> UUID
    public typealias DateFactory = @Sendable () -> Date

    private let uuidFactory: UUIDFactory
    private let dateFactory: DateFactory

    public init(
        uuidFactory: @escaping UUIDFactory = { _ in UUID() },
        dateFactory: @escaping DateFactory = Date.init
    ) {
        self.uuidFactory = uuidFactory
        self.dateFactory = dateFactory
    }

    public func map(data: Data) throws -> [TaskItem] {
        let envelope = try JSONDecoder().decode(DummyJSONTodoEnvelope.self, from: data)
        return map(todos: envelope.todos)
    }

    public func map(todos: [DummyJSONTodoDTO]) -> [TaskItem] {
        let createdAt = dateFactory()
        return todos.map { todo in
            TaskItem(
                id: uuidFactory(todo.id),
                remoteID: todo.id,
                title: todo.todo,
                details: "",
                createdAt: createdAt,
                isCompleted: todo.completed
            )
        }
    }
}
