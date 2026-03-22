import UIKit
import TODOCore

@MainActor
enum TaskDetailBuilder {
    static func build(
        dependencies: AppDependencyContainer,
        taskID: UUID?,
        onFinish: @escaping () -> Void
    ) -> UIViewController {
        let viewController = TaskDetailViewController()
        let router = TaskDetailRouter(onFinish: onFinish)
        let interactor = TaskDetailInteractor(taskID: taskID, repository: dependencies.repository)
        let presenter = TaskDetailPresenter(
            view: viewController,
            interactor: interactor,
            router: router,
            dateFormatter: dependencies.dateFormatter
        )

        router.viewController = viewController
        interactor.output = presenter
        viewController.presenter = presenter
        return viewController
    }
}
