import UIKit

final class LoadingFailureView: UIView {
    
    // MARK: - Internal Properties
    
    var onRetryTap: (() -> Void)?
    var onSkipTap: (() -> Void)?
    
    // MARK: - Private Properties
    
    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.textColor = .whiteAsset
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = Constants.loadingFailureMessage
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var retryButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(handleRetryButtonTap), for: .touchUpInside)
        button.setTitle(Constants.retry, for: .normal)
        button.setTitleColor(.yellowAsset, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 12, weight: .medium)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var skipButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(handleSkipButtonTap), for: .touchUpInside)
        button.setTitle(Constants.skip, for: .normal)
        button.setTitleColor(.yellowAsset, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 12, weight: .medium)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var buttonsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [retryButton, skipButton])
        stackView.axis = .horizontal
        stackView.spacing = 32
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
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
    
    // MARK: - Private Methods
    
    private func setupView() {
        addSubview(messageLabel)
        addSubview(buttonsStackView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            messageLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            messageLabel.topAnchor.constraint(equalTo: topAnchor),
            
            buttonsStackView.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 12),
            buttonsStackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            buttonsStackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    @objc private func handleRetryButtonTap() {
        onRetryTap?()
    }
    
    @objc private func handleSkipButtonTap() {
        onSkipTap?()
    }
}

