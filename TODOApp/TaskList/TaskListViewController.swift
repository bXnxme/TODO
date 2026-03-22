import UIKit
import TODOCore

final class TaskListViewController: UIViewController {
    var presenter: TaskListPresenterInput?

    private var items: [TaskListItemViewModel] = []

    private let titleLabel = UILabel()
    private let searchContainerView = UIView()
    private let searchTextField = UITextField()
    private let searchIconView = UIImageView()
    private let voiceSearchButton = UIButton(type: .system)
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let bottomBarView = UIView()
    private let taskCountLabel = UILabel()
    private let composeButton = UIButton(type: .system)
    private let loadingIndicator = UIActivityIndicatorView(style: .medium)
    private let refreshControl = UIRefreshControl()
    private var bottomBarHeightConstraint: NSLayoutConstraint?

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        presenter?.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    private func configureUI() {
        view.backgroundColor = AppTheme.background
        view.insetsLayoutMarginsFromSafeArea = false

        titleLabel.text = "Задачи"
        titleLabel.font = UIFont.systemFont(ofSize: 42, weight: .bold)
        titleLabel.textColor = AppTheme.primaryText

        searchContainerView.backgroundColor = AppTheme.surface
        searchContainerView.layer.cornerRadius = 10

        searchIconView.image = UIImage(systemName: "magnifyingglass")
        searchIconView.tintColor = AppTheme.secondaryText
        searchIconView.contentMode = .scaleAspectFit

        searchTextField.borderStyle = .none
        searchTextField.backgroundColor = .clear
        searchTextField.textColor = AppTheme.primaryText
        searchTextField.tintColor = AppTheme.primaryText
        searchTextField.clearButtonMode = .whileEditing
        searchTextField.autocapitalizationType = .none
        searchTextField.autocorrectionType = .no
        searchTextField.spellCheckingType = .no
        searchTextField.returnKeyType = .search
        searchTextField.attributedPlaceholder = NSAttributedString(
            string: "Search",
            attributes: [.foregroundColor: AppTheme.secondaryText]
        )
        searchTextField.addTarget(self, action: #selector(handleSearchChanged), for: .editingChanged)
        searchTextField.delegate = self

        let searchTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleSearchTapped))
        searchContainerView.addGestureRecognizer(searchTapGesture)

        voiceSearchButton.setImage(UIImage(systemName: "mic.fill"), for: .normal)
        voiceSearchButton.tintColor = AppTheme.secondaryText
        voiceSearchButton.isUserInteractionEnabled = false

        tableView.register(TaskCell.self, forCellReuseIdentifier: TaskCell.reuseIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 90
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.refreshControl = refreshControl
        tableView.contentInset = UIEdgeInsets(top: 4, left: 0, bottom: 0, right: 0)
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        refreshControl.tintColor = AppTheme.accent

        bottomBarView.backgroundColor = AppTheme.surfaceElevated

        taskCountLabel.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        taskCountLabel.textColor = AppTheme.secondaryText
        taskCountLabel.textAlignment = .center
        taskCountLabel.text = AppTheme.taskCountText(for: 0)

        composeButton.setImage(UIImage(systemName: "square.and.pencil"), for: .normal)
        composeButton.tintColor = AppTheme.accent
        composeButton.addTarget(self, action: #selector(handleAddTapped), for: .touchUpInside)

        loadingIndicator.color = AppTheme.accent

        view.addSubview(titleLabel)
        view.addSubview(searchContainerView)
        searchContainerView.addSubview(searchIconView)
        searchContainerView.addSubview(searchTextField)
        searchContainerView.addSubview(voiceSearchButton)
        view.addSubview(tableView)
        view.addSubview(bottomBarView)
        bottomBarView.addSubview(taskCountLabel)
        bottomBarView.addSubview(composeButton)
        view.addSubview(loadingIndicator)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        searchContainerView.translatesAutoresizingMaskIntoConstraints = false
        searchIconView.translatesAutoresizingMaskIntoConstraints = false
        searchTextField.translatesAutoresizingMaskIntoConstraints = false
        voiceSearchButton.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        bottomBarView.translatesAutoresizingMaskIntoConstraints = false
        taskCountLabel.translatesAutoresizingMaskIntoConstraints = false
        composeButton.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false

        let bottomBarHeightConstraint = bottomBarView.heightAnchor.constraint(equalToConstant: 58)
        self.bottomBarHeightConstraint = bottomBarHeightConstraint

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 2),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -18),

            searchContainerView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            searchContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            searchContainerView.heightAnchor.constraint(equalToConstant: 36),

            searchIconView.leadingAnchor.constraint(equalTo: searchContainerView.leadingAnchor, constant: 12),
            searchIconView.centerYAnchor.constraint(equalTo: searchContainerView.centerYAnchor),
            searchIconView.widthAnchor.constraint(equalToConstant: 16),
            searchIconView.heightAnchor.constraint(equalToConstant: 16),

            voiceSearchButton.trailingAnchor.constraint(equalTo: searchContainerView.trailingAnchor, constant: -12),
            voiceSearchButton.centerYAnchor.constraint(equalTo: searchContainerView.centerYAnchor),
            voiceSearchButton.widthAnchor.constraint(equalToConstant: 22),
            voiceSearchButton.heightAnchor.constraint(equalToConstant: 22),

            searchTextField.leadingAnchor.constraint(equalTo: searchIconView.trailingAnchor, constant: 8),
            searchTextField.trailingAnchor.constraint(equalTo: voiceSearchButton.leadingAnchor, constant: -8),
            searchTextField.topAnchor.constraint(equalTo: searchContainerView.topAnchor),
            searchTextField.bottomAnchor.constraint(equalTo: searchContainerView.bottomAnchor),

            tableView.topAnchor.constraint(equalTo: searchContainerView.bottomAnchor, constant: 10),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomBarView.topAnchor),

            bottomBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomBarView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            bottomBarHeightConstraint,

            taskCountLabel.topAnchor.constraint(equalTo: bottomBarView.topAnchor, constant: 12),
            taskCountLabel.centerXAnchor.constraint(equalTo: bottomBarView.centerXAnchor),

            composeButton.centerYAnchor.constraint(equalTo: taskCountLabel.centerYAnchor),
            composeButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -18),
            composeButton.widthAnchor.constraint(equalToConstant: 32),
            composeButton.heightAnchor.constraint(equalToConstant: 32),

            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    @objc
    private func handleAddTapped() {
        presenter?.didTapAddTask()
    }

    @objc
    private func handleRefresh() {
        presenter?.didPullToRefresh()
    }

    @objc
    private func handleSearchChanged() {
        let query = searchTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        presenter?.didSearch(query: query?.isEmpty == true ? nil : query)
    }

    @objc
    private func handleSearchTapped() {
        searchTextField.becomeFirstResponder()
    }

    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    private func updateTaskCount() {
        taskCountLabel.text = AppTheme.taskCountText(for: items.count)
    }

    private func shareTask(at index: Int) {
        guard items.indices.contains(index) else { return }

        let item = items[index]
        var fragments = [item.title]
        if item.hasDetails {
            fragments.append(item.details)
        }

        let controller = UIActivityViewController(activityItems: [fragments.joined(separator: "\n\n")], applicationActivities: nil)
        if let popover = controller.popoverPresentationController {
            popover.sourceView = composeButton
            popover.sourceRect = composeButton.bounds
        }
        present(controller, animated: true)
    }

    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        bottomBarHeightConstraint?.constant = 58 + view.safeAreaInsets.bottom
    }
}

extension TaskListViewController: TaskListView {
    func display(tasks: [TaskListItemViewModel]) {
        items = tasks
        updateTaskCount()
        tableView.reloadData()
        refreshControl.endRefreshing()
    }

    func displayLoading(_ isLoading: Bool) {
        if isLoading {
            loadingIndicator.startAnimating()
        } else {
            loadingIndicator.stopAnimating()
            refreshControl.endRefreshing()
        }
    }

    func displayError(message: String) {
        showAlert(message: message)
    }
}

extension TaskListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(
                withIdentifier: TaskCell.reuseIdentifier,
                for: indexPath
            ) as? TaskCell
        else {
            return UITableViewCell()
        }

        let item = items[indexPath.row]
        cell.configure(with: item)
        cell.onToggle = { [weak self, weak tableView, weak cell] isCompleted in
            guard
                let self,
                let tableView,
                let cell,
                let updatedIndexPath = tableView.indexPath(for: cell)
            else {
                return
            }

            self.presenter?.didChangeCompletion(at: updatedIndexPath.row, isCompleted: isCompleted)
        }
        return cell
    }
}

extension TaskListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        presenter?.didSelectTask(at: indexPath.row)
    }

    func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Удалить") { [weak self] _, _, completion in
            self?.presenter?.didDeleteTask(at: indexPath.row)
            completion(true)
        }

        return UISwipeActionsConfiguration(actions: [deleteAction])
    }

    func tableView(
        _ tableView: UITableView,
        contextMenuConfigurationForRowAt indexPath: IndexPath,
        point: CGPoint
    ) -> UIContextMenuConfiguration? {
        UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ in
            guard let self else {
                return nil
            }

            let edit = UIAction(title: "Редактировать", image: UIImage(systemName: "square.and.pencil")) { _ in
                self.presenter?.didSelectTask(at: indexPath.row)
            }

            let share = UIAction(title: "Поделиться", image: UIImage(systemName: "square.and.arrow.up")) { _ in
                self.shareTask(at: indexPath.row)
            }

            let delete = UIAction(
                title: "Удалить",
                image: UIImage(systemName: "trash"),
                attributes: .destructive
            ) { _ in
                self.presenter?.didDeleteTask(at: indexPath.row)
            }

            return UIMenu(children: [edit, share, delete])
        }
    }
}

extension TaskListViewController: UITextFieldDelegate {
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        presenter?.didSearch(query: nil)
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
