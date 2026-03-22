import UIKit

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    private let dependencies = AppDependencyContainer()

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        let navigationController = UINavigationController()
        navigationController.setNavigationBarHidden(true, animated: false)
        let rootViewController = TaskListBuilder.build(
            navigationController: navigationController,
            dependencies: dependencies
        )

        navigationController.viewControllers = [rootViewController]

        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = navigationController
        window.overrideUserInterfaceStyle = .dark
        window.makeKeyAndVisible()
        self.window = window

        return true
    }
}
