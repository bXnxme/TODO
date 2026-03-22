import UIKit
import TODOCore

@MainActor
final class TaskListRouter: TaskListRouterInput {
    private weak var navigationController: UINavigationController?
    private let dependencies: AppDependencyContainer

    init(navigationController: UINavigationController, dependencies: AppDependencyContainer) {
        self.navigationController = navigationController
        self.dependencies = dependencies
    }

    func showTaskDetail(taskID: UUID?, onFinish: @escaping () -> Void) {
        let viewController = TaskDetailBuilder.build(
            dependencies: dependencies,
            taskID: taskID,
            onFinish: onFinish
        )
        navigationController?.pushViewController(viewController, animated: true)
    }
}
