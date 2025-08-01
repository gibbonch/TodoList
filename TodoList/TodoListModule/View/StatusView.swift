import UIKit

final class StatusView: UIView {
    
    // MARK: - Internal Properties
    
    var onButtonTap: (() -> Void)?
    
    // MARK: - Private Properties
    
    private var currentState: StatusViewState = .loading
    
    private lazy var blurView: UIVisualEffectView = {
        let effect = UIBlurEffect(style: .systemThinMaterialDark)
        let view = UIVisualEffectView(effect: effect)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var addButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        let image = UIImage.createAsset
            .scaled(size: CGSize(width: 25, height: 25))
            .withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    private lazy var statusLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 11, weight: .regular)
        label.textColor = .whiteAsset
        label.textAlignment = .center
        label.text = "Loading..."
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupConstraints()
        updateUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Internal Methods
    
    func updateState(with newState: StatusViewState) {
        currentState = newState
        updateUI()
    }
    
    // MARK: - Private Methods
    
    private func setupView() {
        backgroundColor = .clear
        addSubview(blurView)
        addSubview(addButton)
        addSubview(statusLabel)
        addSubview(loadingIndicator)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            blurView.leadingAnchor.constraint(equalTo: leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: trailingAnchor),
            blurView.topAnchor.constraint(equalTo: topAnchor),
            blurView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            addButton.heightAnchor.constraint(equalToConstant: 44),
            addButton.widthAnchor.constraint(equalToConstant: 68),
            addButton.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            addButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            statusLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            statusLabel.centerYAnchor.constraint(equalTo: addButton.centerYAnchor),
            
            loadingIndicator.heightAnchor.constraint(equalToConstant: 12),
            loadingIndicator.widthAnchor.constraint(equalToConstant: 12),
            loadingIndicator.trailingAnchor.constraint(equalTo: statusLabel.leadingAnchor, constant: -5),
            loadingIndicator.centerYAnchor.constraint(equalTo: addButton.centerYAnchor)
        ])
    }
    
    private func updateUI() {
        statusLabel.text = currentState.title
        if case .loading = currentState {
            loadingIndicator.startAnimating()
        } else {
            loadingIndicator.stopAnimating()
        }
    }
    
    @objc private func addButtonTapped() {
        onButtonTap?()
    }
}

// MARK: - StatusViewState

enum StatusViewState {
    
    case loading
    case tasks(Int)
    case loadingFailure
    
    var title: String {
        switch self {
        case .loading:
            return Constants.loading
        case .tasks(let count):
            if count == 0 {
                return Constants.emptyTasks
            }
            return "\(count) \(taskWord(for: count))"
        case .loadingFailure:
            return Constants.loadingError
        }
    }
    
    private func taskWord(for count: Int) -> String {
        let lastDigit = count % 10
        let lastTwoDigits = count % 100
        
        if lastTwoDigits >= 11 && lastTwoDigits <= 14 {
            return "Задач"
        }
        
        switch lastDigit {
        case 1:
            return "Задача"
        case 2, 3, 4:
            return "Задачи"
        default:
            return "Задач"
        }
    }
}
