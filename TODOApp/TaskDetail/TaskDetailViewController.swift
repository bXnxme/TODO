import UIKit
import TODOCore

final class TaskDetailViewController: UIViewController {
    var presenter: TaskDetailPresenterInput?

    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let completionContainerView = UIView()
    private let backButton = UIButton(type: .system)
    private let saveButton = UIButton(type: .system)
    private let titleField = UITextField()
    private let createdAtLabel = UILabel()
    private let descriptionTextView = UITextView()
    private let descriptionPlaceholderLabel = UILabel()
    private let completionStackView = UIStackView()
    private let completionButton = UIButton(type: .system)
    private let completionLabel = UILabel()
    private var completionContainerHeightConstraint: NSLayoutConstraint?

    private var isCompleted = false

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

        scrollView.keyboardDismissMode = .interactive
        scrollView.alwaysBounceVertical = true
        scrollView.contentInsetAdjustmentBehavior = .never

        backButton.setTitle("Назад", for: .normal)
        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backButton.tintColor = AppTheme.accent
        backButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        backButton.semanticContentAttribute = .forceLeftToRight
        backButton.contentHorizontalAlignment = .leading
        backButton.addTarget(self, action: #selector(handleBackTapped), for: .touchUpInside)

        saveButton.setTitle("Сохранить", for: .normal)
        saveButton.setTitleColor(AppTheme.accent, for: .normal)
        saveButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        saveButton.contentHorizontalAlignment = .trailing
        saveButton.addTarget(self, action: #selector(handleSaveTapped), for: .touchUpInside)

        titleField.backgroundColor = .clear
        titleField.borderStyle = .none
        titleField.textColor = AppTheme.primaryText
        titleField.tintColor = AppTheme.primaryText
        titleField.font = UIFont.systemFont(ofSize: 40, weight: .bold)
        titleField.attributedPlaceholder = NSAttributedString(
            string: "Название задачи",
            attributes: [.foregroundColor: AppTheme.tertiaryText]
        )
        titleField.returnKeyType = .next
        titleField.delegate = self

        createdAtLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        createdAtLabel.textColor = AppTheme.tertiaryText
        createdAtLabel.numberOfLines = 1

        descriptionTextView.backgroundColor = .clear
        descriptionTextView.textColor = AppTheme.primaryText
        descriptionTextView.tintColor = AppTheme.primaryText
        descriptionTextView.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        descriptionTextView.textContainerInset = .zero
        descriptionTextView.textContainer.lineFragmentPadding = 0
        descriptionTextView.delegate = self
        descriptionTextView.isScrollEnabled = false

        descriptionPlaceholderLabel.text = "Описание"
        descriptionPlaceholderLabel.textColor = AppTheme.tertiaryText
        descriptionPlaceholderLabel.font = descriptionTextView.font

        completionContainerView.backgroundColor = AppTheme.background

        completionStackView.axis = .horizontal
        completionStackView.alignment = .center
        completionStackView.spacing = 10

        completionButton.tintColor = AppTheme.secondaryText
        completionButton.contentHorizontalAlignment = .leading
        completionButton.addTarget(self, action: #selector(handleCompletionTapped), for: .touchUpInside)

        completionLabel.text = "Выполнено"
        completionLabel.textColor = AppTheme.secondaryText
        completionLabel.font = UIFont.systemFont(ofSize: 17, weight: .medium)

        view.addSubview(scrollView)
        view.addSubview(completionContainerView)
        scrollView.addSubview(contentView)
        contentView.addSubview(backButton)
        contentView.addSubview(saveButton)
        contentView.addSubview(titleField)
        contentView.addSubview(createdAtLabel)
        contentView.addSubview(descriptionTextView)
        descriptionTextView.addSubview(descriptionPlaceholderLabel)
        completionContainerView.addSubview(completionStackView)
        completionStackView.addArrangedSubview(completionLabel)
        completionStackView.addArrangedSubview(completionButton)

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        completionContainerView.translatesAutoresizingMaskIntoConstraints = false
        completionStackView.translatesAutoresizingMaskIntoConstraints = false
        backButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        titleField.translatesAutoresizingMaskIntoConstraints = false
        createdAtLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionTextView.translatesAutoresizingMaskIntoConstraints = false
        descriptionPlaceholderLabel.translatesAutoresizingMaskIntoConstraints = false
        completionButton.translatesAutoresizingMaskIntoConstraints = false
        completionLabel.translatesAutoresizingMaskIntoConstraints = false

        let completionContainerHeightConstraint = completionContainerView.heightAnchor.constraint(equalToConstant: 82)
        self.completionContainerHeightConstraint = completionContainerHeightConstraint

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: completionContainerView.topAnchor),

            completionContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            completionContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            completionContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            completionContainerHeightConstraint,

            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            contentView.heightAnchor.constraint(greaterThanOrEqualTo: scrollView.frameLayoutGuide.heightAnchor),

            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 2),
            backButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            backButton.heightAnchor.constraint(equalToConstant: 30),

            saveButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            saveButton.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),

            titleField.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 12),
            titleField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 18),
            titleField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -18),

            createdAtLabel.topAnchor.constraint(equalTo: titleField.bottomAnchor, constant: 10),
            createdAtLabel.leadingAnchor.constraint(equalTo: titleField.leadingAnchor),
            createdAtLabel.trailingAnchor.constraint(equalTo: titleField.trailingAnchor),

            descriptionTextView.topAnchor.constraint(equalTo: createdAtLabel.bottomAnchor, constant: 22),
            descriptionTextView.leadingAnchor.constraint(equalTo: titleField.leadingAnchor),
            descriptionTextView.trailingAnchor.constraint(equalTo: titleField.trailingAnchor),
            descriptionTextView.heightAnchor.constraint(greaterThanOrEqualToConstant: 220),
            descriptionTextView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24),

            descriptionPlaceholderLabel.topAnchor.constraint(equalTo: descriptionTextView.topAnchor),
            descriptionPlaceholderLabel.leadingAnchor.constraint(equalTo: descriptionTextView.leadingAnchor),
            descriptionPlaceholderLabel.trailingAnchor.constraint(lessThanOrEqualTo: descriptionTextView.trailingAnchor),

            completionStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -18),
            completionStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),

            completionButton.widthAnchor.constraint(equalToConstant: 28),
            completionButton.heightAnchor.constraint(equalToConstant: 28),
            completionLabel.leadingAnchor.constraint(greaterThanOrEqualTo: completionContainerView.leadingAnchor, constant: 18)
        ])

        updateCompletionAppearance()
        updateDescriptionPlaceholder()
    }

    @objc
    private func handleBackTapped() {
        if let navigationController {
            navigationController.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }

    @objc
    private func handleSaveTapped() {
        presenter?.didTapSave(
            title: titleField.text ?? "",
            details: descriptionTextView.text ?? "",
            isCompleted: isCompleted
        )
    }

    @objc
    private func handleCompletionTapped() {
        isCompleted.toggle()
        updateCompletionAppearance()
        presenter?.didChangeCompletion(isCompleted: isCompleted)
    }

    private func updateCompletionAppearance() {
        let imageName = isCompleted ? "checkmark.circle.fill" : "circle"
        completionButton.setImage(UIImage(systemName: imageName), for: .normal)
        completionButton.tintColor = isCompleted ? AppTheme.accent : AppTheme.secondaryText
    }

    private func updateDescriptionPlaceholder() {
        descriptionPlaceholderLabel.isHidden = !descriptionTextView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        completionContainerHeightConstraint?.constant = 48 + view.safeAreaInsets.bottom
    }
}

extension TaskDetailViewController: TaskDetailView {
    func display(viewModel: TaskDetailViewModel) {
        saveButton.setTitle(viewModel.saveButtonTitle, for: .normal)
        titleField.text = viewModel.title
        createdAtLabel.text = AppTheme.compactDate(from: viewModel.createdAtText)
        descriptionTextView.text = viewModel.details
        isCompleted = viewModel.isCompleted
        updateCompletionAppearance()
        updateDescriptionPlaceholder()
    }

    func displaySaving(_ isSaving: Bool) {
        saveButton.isEnabled = !isSaving
        saveButton.alpha = isSaving ? 0.5 : 1
        backButton.isEnabled = !isSaving
        titleField.isEnabled = !isSaving
        descriptionTextView.isEditable = !isSaving
        completionButton.isEnabled = !isSaving
    }

    func displayError(message: String) {
        showAlert(message: message)
    }
}

extension TaskDetailViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        descriptionTextView.becomeFirstResponder()
        return true
    }
}

extension TaskDetailViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        updateDescriptionPlaceholder()
    }
}
