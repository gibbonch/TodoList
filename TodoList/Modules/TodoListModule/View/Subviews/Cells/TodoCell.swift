import UIKit

final class TodoCell: UITableViewCell {
    
    // MARK: - Internal Poperties
    
    var onToggleCompletion: (() -> Void)?
    
    var preview: TodoView {
        todoView
    }
    
    // MARK: - Private Properties
    
    private lazy var completionButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(completionButtonTapped), for: .touchUpInside)
        button.layer.cornerRadius = 12
        button.layer.borderWidth = 1
        button.tintColor = .yellowAsset
        button.setImage(.tickAsset, for: .selected)
        button.setImage(nil, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var todoView: TodoView = {
        let view = TodoView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var separator: UIView = {
        let view = UIView()
        view.backgroundColor = .strokeAsset
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Lifecycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        separator.isHidden = false
    }
    
    // MARK: - Internal Methods
    
    func configure(with model: TodoCellModel) {
        let isCompleted = model.isCompleted
        completionButton.isSelected = isCompleted
        completionButton.layer.borderColor = isCompleted ? UIColor.yellowAsset.cgColor : UIColor.strokeAsset.cgColor
        
        todoView.configure(todo: model)
        
        layoutIfNeeded()
    }
    
    func hideSeparator() {
        separator.isHidden = true
    }
    
    // MARK: - Private Methods
    
    private func setupCell() {
        backgroundColor = .blackAsset
        contentView.addSubview(completionButton)
        contentView.addSubview(todoView)
        contentView.addSubview(separator)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            completionButton.widthAnchor.constraint(equalToConstant: 24),
            completionButton.heightAnchor.constraint(equalToConstant: 24),
            completionButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            completionButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            
            todoView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            todoView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            todoView.leadingAnchor.constraint(equalTo: completionButton.trailingAnchor, constant: 8),
            todoView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            separator.heightAnchor.constraint(equalToConstant: 0.5),
            separator.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            separator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            separator.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
    }
    
    @objc private func completionButtonTapped() {
        onToggleCompletion?()
    }
}

// MARK: - TodoCellModel

struct TodoCellModel {
    let title: String
    let task: String
    let date: String
    let isCompleted: Bool
}
