import UIKit

final class TodoPlaceholderCell: UITableViewCell {
    
    // MARK: - Private Properties
    
    private lazy var titlePlaceholder: ShimmerView = {
        let view = ShimmerView()
        view.backgroundColor = .clear
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 11
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var taskPlaceholder: ShimmerView = {
        let view = ShimmerView()
        view.backgroundColor = .clear
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var datePlaceholder: ShimmerView = {
        let view = ShimmerView()
        view.backgroundColor = .clear
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 8
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
        stopShimmering()
        separator.isHidden = false
    }
    
    // MARK: - Internal Methods
    
    func hideSeparator() {
        separator.isHidden = true
    }
    
    // MARK: - Private Methods
    
    private func setupCell() {
        backgroundColor = .clear
        contentView.addSubview(titlePlaceholder)
        contentView.addSubview(taskPlaceholder)
        contentView.addSubview(datePlaceholder)
        contentView.addSubview(separator)
    }
    
    private func setupConstraints() {
        let totalWidth = UIScreen.main.bounds.width
        let leftInset: CGFloat = 52
        let rightInset: CGFloat = 20
        let availableWidth = totalWidth - leftInset - rightInset
        
        let titleWidth = availableWidth * 0.5
        let taskWidth = availableWidth * 0.8
        let dateWidth = availableWidth * 0.2
        
        NSLayoutConstraint.activate([
            titlePlaceholder.heightAnchor.constraint(equalToConstant: 22),
            titlePlaceholder.widthAnchor.constraint(equalToConstant: titleWidth),
            titlePlaceholder.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: leftInset),
            titlePlaceholder.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            
            taskPlaceholder.heightAnchor.constraint(equalToConstant: 16),
            taskPlaceholder.widthAnchor.constraint(equalToConstant: taskWidth),
            taskPlaceholder.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: leftInset),
            taskPlaceholder.topAnchor.constraint(equalTo: titlePlaceholder.bottomAnchor, constant: 6),
            
            datePlaceholder.heightAnchor.constraint(equalToConstant: 16),
            datePlaceholder.widthAnchor.constraint(equalToConstant: dateWidth),
            datePlaceholder.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: leftInset),
            datePlaceholder.topAnchor.constraint(equalTo: taskPlaceholder.bottomAnchor, constant: 6),
            datePlaceholder.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            
            separator.heightAnchor.constraint(equalToConstant: 0.5),
            separator.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            separator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            separator.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
    }
    
    private func stopShimmering() {
        titlePlaceholder.stopAnimating()
        taskPlaceholder.stopAnimating()
        datePlaceholder.stopAnimating()
    }
}
