import Foundation

public struct TaskItem: Equatable, Identifiable, Sendable {
    public let id: UUID
    public let remoteID: Int?
    public var title: String
    public var details: String
    public let createdAt: Date
    public var isCompleted: Bool

    public init(
        id: UUID,
        remoteID: Int? = nil,
        title: String,
        details: String,
        createdAt: Date,
        isCompleted: Bool
    ) {
        self.id = id
        self.remoteID = remoteID
        self.title = title
        self.details = details
        self.createdAt = createdAt
        self.isCompleted = isCompleted
    }
}

