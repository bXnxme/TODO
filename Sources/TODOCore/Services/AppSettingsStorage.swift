import Foundation

public protocol AppSettingsStorage: AnyObject {
    var hasLoadedInitialTasks: Bool { get set }
}

public final class UserDefaultsAppSettings: AppSettingsStorage {
    private let defaults: UserDefaults
    private let key: String

    public init(defaults: UserDefaults = .standard, key: String = "hasLoadedInitialTasks") {
        self.defaults = defaults
        self.key = key
    }

    public var hasLoadedInitialTasks: Bool {
        get { defaults.bool(forKey: key) }
        set { defaults.set(newValue, forKey: key) }
    }
}

