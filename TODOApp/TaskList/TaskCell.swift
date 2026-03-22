import UIKit
import TODOCore

final class TaskCell: UITableViewCell {
    static let reuseIdentifier = "TaskCell"

    var onToggle: ((Bool) -> Void)?

    private let completionButton = UIButton(type: .system)
    private let titleLabel = UILabel()
    private let detailsLabel = UILabel()
    private let createdAtLabel = UILabel()
    private let separatorView = UIView()

    private var isCompleted = false

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        configureLayout()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with viewModel: TaskListItemViewModel) {
        isCompleted = viewModel.isCompleted
        titleLabel.attributedText = makeTitleText(viewModel.title, isCompleted: viewModel.isCompleted)
        detailsLabel.text = viewModel.details
        detailsLabel.isHidden = !viewModel.hasDetails
        detailsLabel.textColor = viewModel.isCompleted ? AppTheme.tertiaryText : AppTheme.secondaryText
        createdAtLabel.text = AppTheme.compactDate(from: viewModel.createdAtText)
        completionButton.setImage(
            UIImage(systemName: viewModel.isCompleted ? "checkmark.circle.fill" : "circle"),
            for: .normal
        )
        completionButton.tintColor = viewModel.isCompleted ? AppTheme.accent : AppTheme.tertiaryText
    }

    private func configureLayout() {
        completionButton.contentVerticalAlignment = .top
        completionButton.contentHorizontalAlignment = .center
        completionButton.addTarget(self, action: #selector(handleToggleTapped), for: .touchUpInside)
        completionButton.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.numberOfLines = 2
        detailsLabel.numberOfLines = 3
        detailsLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)

        createdAtLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        createdAtLabel.textColor = AppTheme.tertiaryText

        separatorView.backgroundColor = AppTheme.separator

        let labelsStack = UIStackView(arrangedSubviews: [titleLabel, detailsLabel, createdAtLabel])
        labelsStack.axis = .vertical
        labelsStack.alignment = .fill
        labelsStack.spacing = 6

        let contentStack = UIStackView(arrangedSubviews: [completionButton, labelsStack])
        contentStack.axis = .horizontal
        contentStack.alignment = .top
        contentStack.spacing = 12

        contentView.addSubview(contentStack)
        contentView.addSubview(separatorView)
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        separatorView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            completionButton.widthAnchor.constraint(equalToConstant: 24),
            completionButton.heightAnchor.constraint(equalToConstant: 24),

            contentStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 14),
            contentStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 18),
            contentStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -18),
            contentStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -14),

            separatorView.heightAnchor.constraint(equalToConstant: 1),
            separatorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 18),
            separatorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -18),
            separatorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }

    @objc
    private func handleToggleTapped() {
        onToggle?(!isCompleted)
    }

    private func makeTitleText(_ text: String, isCompleted: Bool) -> NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byTruncatingTail

        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 18, weight: .semibold),
            .foregroundColor: isCompleted ? AppTheme.secondaryText : AppTheme.primaryText,
            .paragraphStyle: paragraphStyle,
            .strikethroughStyle: isCompleted ? NSUnderlineStyle.single.rawValue : 0,
            .strikethroughColor: isCompleted ? AppTheme.secondaryText : UIColor.clear
        ]

        return NSAttributedString(string: text, attributes: attributes)
    }
}
