import Foundation

public struct TaskDraft: Equatable, Sendable {
    public var title: String
    public var details: String
    public var isCompleted: Bool

    public init(title: String, details: String, isCompleted: Bool) {
        self.title = title
        self.details = details
        self.isCompleted = isCompleted
    }
}

