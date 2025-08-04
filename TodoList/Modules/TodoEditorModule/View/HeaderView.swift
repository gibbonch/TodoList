import UIKit

final class HeaderView: UIView {
    
    // MARK: - Internal Properties
    
    var onCloseButtonTapped: (() -> Void)?
    var onPreviousButtonTapped: (() -> Void)?
    var onNextButtonTapped: (() -> Void)?
    
    // MARK: - Private Properties
    
    private var currentState = HeaderViewState()
    
    private lazy var blurView: UIVisualEffectView = {
        let effect = UIBlurEffect(style: .systemMaterialDark)
        let view = UIVisualEffectView(effect: effect)
        view.alpha = 1
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .whiteAsset
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var closeButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        let image = UIImage.crossAsset
            .scaled(size: CGSize(width: 12, height: 12))
            .withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)
        button.tintColor = .whiteAsset
        button.backgroundColor = .grayAsset
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var previousButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(previousButtonTapped), for: .touchUpInside)
        let image = UIImage.previousAsset
            .scaled(size: CGSize(width: 20, height: 20))
            .withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)
        button.tintColor = .yellowAsset
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var nextButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        let image = UIImage.nextAsset
            .scaled(size: CGSize(width: 20, height: 20))
            .withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)
        button.tintColor = .yellowAsset
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var historyStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [previousButton, nextButton])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
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
    
    func setBlurAlpha(_ alpha: CGFloat) {
        blurView.alpha = alpha
        closeButton.backgroundColor = .grayAsset.withAlphaComponent(1 - alpha)
    }
    
    func updateState(with newState: HeaderViewState) {
        currentState = newState
        updateUI()
    }
    
    func setTitle(_ title: String) {
        titleLabel.text = title
    }
    
    // MARK: - Private Methods
    
    private func setupView() {
        backgroundColor = .clear
        addSubview(blurView)
        addSubview(titleLabel)
        addSubview(closeButton)
        addSubview(historyStackView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            blurView.leadingAnchor.constraint(equalTo: leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: trailingAnchor),
            blurView.topAnchor.constraint(equalTo: topAnchor),
            blurView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            closeButton.heightAnchor.constraint(equalToConstant: 24),
            closeButton.widthAnchor.constraint(equalToConstant: 24),
            closeButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            closeButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            previousButton.widthAnchor.constraint(equalToConstant: 24),
            previousButton.heightAnchor.constraint(equalToConstant: 24),
            
            nextButton.widthAnchor.constraint(equalToConstant: 24),
            nextButton.heightAnchor.constraint(equalToConstant: 24),
            
            historyStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            historyStackView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    private func updateUI() {
        historyStackView.isHidden = !currentState.isHistoryVisible
        nextButton.isUserInteractionEnabled = currentState.hasNextState
        nextButton.tintColor = currentState.hasNextState ? .yellowAsset : .lightGrayAsset
        previousButton.isUserInteractionEnabled = currentState.hasPreviousState
        previousButton.tintColor = currentState.hasPreviousState ? .yellowAsset : .lightGrayAsset
    }
    
    @objc private func closeButtonTapped() {
        onCloseButtonTapped?()
    }
    
    @objc private func previousButtonTapped() {
        onPreviousButtonTapped?()
    }
    
    @objc private func nextButtonTapped() {
        onNextButtonTapped?()
    }
}

// MARK: - HeaderViewState

struct HeaderViewState {
    
    var isHistoryVisible: Bool = false
    var hasPreviousState: Bool = false
    var hasNextState: Bool = false
}
