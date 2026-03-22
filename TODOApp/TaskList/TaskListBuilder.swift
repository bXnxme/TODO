import UIKit
import TODOCore

@MainActor
enum TaskListBuilder {
    static func build(
        navigationController: UINavigationController,
        dependencies: AppDependencyContainer
    ) -> UIViewController {
        let viewController = TaskListViewController()
        let router = TaskListRouter(
            navigationController: navigationController,
            dependencies: dependencies
        )
        let interactor = TaskListInteractor(
            repository: dependencies.repository,
            initialLoader: dependencies.initialLoader
        )
        let presenter = TaskListPresenter(
            view: viewController,
            interactor: interactor,
            router: router,
            dateFormatter: dependencies.dateFormatter
        )

        interactor.output = presenter
        viewController.presenter = presenter
        return viewController
    }
}
