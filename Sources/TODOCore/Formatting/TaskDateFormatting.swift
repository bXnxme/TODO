import Foundation

public protocol TaskDateFormatting {
    func string(from date: Date) -> String
}

public final class TaskDateFormatter: TaskDateFormatting {
    private let formatter: DateFormatter

    public init(locale: Locale = Locale(identifier: "ru_RU"), timeZone: TimeZone = .current) {
        let formatter = DateFormatter()
        formatter.locale = locale
        formatter.timeZone = timeZone
        formatter.dateFormat = "dd/MM/yy"
        self.formatter = formatter
    }

    public func string(from date: Date) -> String {
        formatter.string(from: date)
    }
}
