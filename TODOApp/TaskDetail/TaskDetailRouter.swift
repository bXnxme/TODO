import UIKit
import TODOCore

@MainActor
final class TaskDetailRouter: TaskDetailRouterInput {
    weak var viewController: UIViewController?

    private let onFinish: () -> Void

    init(onFinish: @escaping () -> Void) {
        self.onFinish = onFinish
    }

    func close(afterSave: Bool) {
        if afterSave {
            onFinish()
        }

        if let navigationController = viewController?.navigationController {
            navigationController.popViewController(animated: true)
        } else {
            viewController?.dismiss(animated: true)
        }
    }

    func notifyTaskDidChange() {
        onFinish()
    }
}
