import UIKit

enum AppTheme {
    static let background = UIColor.black
    static let surface = UIColor(red: 28 / 255, green: 28 / 255, blue: 30 / 255, alpha: 1)
    static let surfaceElevated = UIColor(red: 44 / 255, green: 44 / 255, blue: 46 / 255, alpha: 1)
    static let separator = UIColor(red: 38 / 255, green: 38 / 255, blue: 40 / 255, alpha: 1)
    static let primaryText = UIColor.white
    static let secondaryText = UIColor(red: 142 / 255, green: 142 / 255, blue: 147 / 255, alpha: 1)
    static let tertiaryText = UIColor(red: 99 / 255, green: 99 / 255, blue: 102 / 255, alpha: 1)
    static let accent = UIColor(red: 1, green: 214 / 255, blue: 10 / 255, alpha: 1)

    static func compactDate(from value: String) -> String {
        value.replacingOccurrences(of: "Создана ", with: "")
    }

    static func taskCountText(for count: Int) -> String {
        let remainder10 = count % 10
        let remainder100 = count % 100

        let suffix: String
        if remainder10 == 1 && remainder100 != 11 {
            suffix = "Задача"
        } else if (2...4).contains(remainder10) && !(12...14).contains(remainder100) {
            suffix = "Задачи"
        } else {
            suffix = "Задач"
        }

        return "\(count) \(suffix)"
    }
}
