import UIKit

final class TodoView: UIView {
    
    // MARK: - Private Properties
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .left
        label.textColor = .whiteAsset
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var taskLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textAlignment = .left
        label.numberOfLines = 2
        label.textColor = .whiteAsset
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textAlignment = .left
        label.numberOfLines = 2
        label.textColor = .lightGrayAsset
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Internal Methods
    
    func configure(todo: TodoCellModel) {
        if todo.isCompleted {
            let attributedString = NSMutableAttributedString(string: todo.title)
            attributedString.addAttribute(.strikethroughStyle,
                                          value: NSUnderlineStyle.single.rawValue,
                                          range: NSRange(location: 0, length: todo.title.count))
            attributedString.addAttribute(.foregroundColor,
                                          value: UIColor.lightGrayAsset,
                                          range: NSRange(location: 0, length: todo.title.count))
            titleLabel.attributedText = attributedString
        } else {
            titleLabel.attributedText = nil
            titleLabel.text = todo.title
            titleLabel.textColor = .whiteAsset
        }
        
        taskLabel.text = todo.task
        taskLabel.textColor = todo.isCompleted ? .lightGrayAsset : .whiteAsset
        dateLabel.text = todo.date
    }
    
    // MARK: - Private Methods
    
    private func setupView() {
        backgroundColor = .clear
        addSubview(titleLabel)
        addSubview(taskLabel)
        addSubview(dateLabel)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            taskLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            taskLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            taskLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            dateLabel.topAnchor.constraint(equalTo: taskLabel.bottomAnchor, constant: 6),
            dateLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            dateLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            dateLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
}
