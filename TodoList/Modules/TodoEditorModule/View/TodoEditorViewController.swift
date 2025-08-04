import UIKit
import Combine

final class TodoEditorViewController: UIViewController {
    
    // MARK: - Internal Properties
    
    var presenter: TodoEditorPresenterProtocol?
    
    // MARK: - Private Properties
    
    private let titleSubject: PassthroughSubject<String, Never> = .init()
    private let taskSubject: PassthroughSubject<String, Never> = .init()
    private var cancellables: Set<AnyCancellable> = []
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.delegate = self
        scrollView.showsVerticalScrollIndicator = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.contentInset.top = 44
        scrollView.contentInset.bottom = 10
        scrollView.delaysContentTouches = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private lazy var titleTextField: UITextField = {
        let textField = UITextField()
        textField.delegate = self
        textField.backgroundColor = .grayAsset
        textField.textColor = .whiteAsset
        textField.layer.cornerRadius = 12
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 60))
        textField.leftViewMode = .always
        textField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 60))
        textField.rightViewMode = .unlessEditing
        textField.clearButtonMode = .whileEditing
        textField.font = .systemFont(ofSize: 17, weight: .regular)
        textField.attributedPlaceholder = NSAttributedString(
            string: Constants.titlePlaceholder,
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGrayAsset]
        )
        textField.tintColor = .yellowAsset
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private lazy var taskTextView: UITextView = {
        let textView = UITextView()
        textView.delegate = self
        textView.backgroundColor = .grayAsset
        textView.textColor = .whiteAsset
        textView.layer.cornerRadius = 12
        textView.font = .systemFont(ofSize: 17)
        let lineHeight = textView.font?.lineHeight ?? 0
        let vInset = (60.0 - lineHeight) / 2
        textView.textContainerInset = UIEdgeInsets(top: vInset, left: 7, bottom: vInset, right: 10)
        textView.tintColor = .yellowAsset
        textView.isScrollEnabled = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    private lazy var taskPlaceholderLabel: UILabel = {
        let label = UILabel()
        label.text = Constants.taskPlaceholder
        label.font = .systemFont(ofSize: 17)
        label.textColor = .lightGrayAsset
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var headerView: HeaderView = {
        let view = HeaderView()
        view.onCloseButtonTapped = { [weak self] in
            self?.dismiss(animated: true)
        }
        view.onNextButtonTapped = { [weak presenter] in
            presenter?.nextTapped()
        }
        view.onPreviousButtonTapped = { [weak presenter] in
            presenter?.previousTapped()
        }
        view.tintColor = .yellowAsset
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var saveButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        button.setTitle(Constants.save, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        button.backgroundColor = .grayAsset
        button.setTitleColor(.yellowAsset, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.shadowColor = UIColor.blackAsset.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: -3)
        button.layer.shadowOpacity = 1
        button.layer.shadowRadius = 3
        button.layer.masksToBounds = false
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Lifecycle
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
        setupGestures()
        setupKeyboardObservers()
        setupBindings()
        presentationController?.delegate = self
        presenter?.viewLoaded()
    }
    
    // MARK: - Private Methods
    
    private func setupView() {
        view.backgroundColor = .blackAsset
        
        contentView.addSubview(titleTextField)
        contentView.addSubview(taskTextView)
        contentView.addSubview(taskPlaceholderLabel)
        scrollView.addSubview(contentView)
        view.addSubview(scrollView)
        view.addSubview(saveButton)
        view.addSubview(headerView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.topAnchor.constraint(equalTo: view.topAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 52),
            
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: saveButton.topAnchor, constant: 5),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            titleTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            titleTextField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            titleTextField.heightAnchor.constraint(equalToConstant: 60),
            
            taskTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            taskTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            taskTextView.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 24),
            taskTextView.heightAnchor.constraint(greaterThanOrEqualToConstant: 60),
            taskTextView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            
            taskPlaceholderLabel.leadingAnchor.constraint(equalTo: taskTextView.leadingAnchor, constant: 12),
            taskPlaceholderLabel.trailingAnchor.constraint(equalTo: taskTextView.trailingAnchor, constant: -10),
            taskPlaceholderLabel.centerYAnchor.constraint(equalTo: taskTextView.centerYAnchor),
            
            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            saveButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    private func setupGestures() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    private func setupBindings() {
        titleSubject
            .debounce(for: 0.1, scheduler: DispatchQueue.main)
            .sink { [weak presenter] title in
                presenter?.titleChanged(title)
            }
            .store(in: &cancellables)
        
        taskSubject
            .debounce(for: 0.1, scheduler: DispatchQueue.main)
            .sink { [weak presenter] task in
                presenter?.taskChanged(task)
            }
            .store(in: &cancellables)
    }
    
    private func updateBlurEffect() {
        let offsetY = scrollView.contentOffset.y + 44
        
        let fadeThreshold: CGFloat = 5
        let alpha = min(1, max(0, offsetY / fadeThreshold))
        
        headerView.setBlurAlpha(alpha)
    }
    
    private func presentWarningAlert() {
        let alert = UIAlertController(
            title: Constants.alertTitle,
            message: Constants.alertMessage,
            preferredStyle: .alert
        )
        let dismissAction = UIAlertAction(title: Constants.alertDismiss, style: .destructive) { [weak self] _ in
            self?.dismiss(animated: true)
        }
        let cancelAction = UIAlertAction(title: Constants.alertCancel, style: .cancel)
        alert.addAction(dismissAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
        
    }
    
    @objc private func hideKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardHeight = keyboardFrame.cgRectValue.height
        
        scrollView.contentInset.bottom = keyboardHeight + 10
        
        if #available(iOS 13.0, *) {
            scrollView.verticalScrollIndicatorInsets.bottom = keyboardHeight + 10
        } else {
            scrollView.scrollIndicatorInsets.bottom = keyboardHeight + 10
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.scrollToCursor()
        }
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        scrollView.contentInset.bottom = 10
        
        if #available(iOS 13.0, *) {
            scrollView.verticalScrollIndicatorInsets.bottom = 10
        } else {
            scrollView.scrollIndicatorInsets.bottom = 10
        }
    }
    
    @objc private func saveButtonTapped() {
        presenter?.saveTapped()
    }
}

// MARK: - TodoEditorViewProtocol

extension TodoEditorViewController: TodoEditorViewProtocol {
    
    func updateState(with newState: TodoEditorViewState) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            
            titleTextField.text = newState.title
            taskTextView.text = newState.task
            taskPlaceholderLabel.isHidden = !newState.task.isEmpty
            
            saveButton.isUserInteractionEnabled = newState.isValid
            saveButton.setTitleColor(newState.isValid ? .yellowAsset : .lightGrayAsset, for: .normal)
            
            headerView.updateState(with: newState.headerViewState)
        }
    }
    
    func setTitle(_ title: String) {
        headerView.setTitle(title)
    }
    
    func dismiss() {
        DispatchQueue.main.async { [weak self] in
            self?.dismiss(animated: true)
        }
    }
}

// MARK: - UITextFieldDelegate

extension TodoEditorViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        titleSubject.send(updatedText)
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        titleSubject.send("")
        return true
    }
}

// MARK: - UITextViewDelegate

extension TodoEditorViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        taskPlaceholderLabel.isHidden = !textView.text.isEmpty
        taskSubject.send(textView.text ?? "")
        
        scrollToCursor()
    }
    
    func textView(_ textView: UITextView,
                  shouldChangeTextIn range: NSRange,
                  replacementText text: String) -> Bool {
        if text == "\n" {
            let currentCursorPosition = range.location
            
            let currentText = textView.text ?? ""
            let newText = (currentText as NSString).replacingCharacters(in: range, with: "\n")
            textView.text = newText
            
            let newCursorPosition = currentCursorPosition + 1
            if let newPosition = textView.position(from: textView.beginningOfDocument, offset: newCursorPosition) {
                textView.selectedTextRange = textView.textRange(from: newPosition, to: newPosition)
            }
            
            taskPlaceholderLabel.isHidden = true
            taskSubject.send(newText)
            
            return false
        }
        
        return true
    }
    
    private func scrollToCursor() {
        guard taskTextView.isFirstResponder else { return }
        
        taskTextView.layoutIfNeeded()
        
        guard let selectedRange = taskTextView.selectedTextRange else { return }
        let caretRect = taskTextView.caretRect(for: selectedRange.start)
        
        let caretRectInContentView = taskTextView.convert(caretRect, to: contentView)
        
        let topInset = scrollView.contentInset.top
        let bottomInset = scrollView.contentInset.bottom
        let visibleHeight = scrollView.frame.height - topInset - bottomInset
        
        let visibleTop = scrollView.contentOffset.y + topInset
        let visibleBottom = visibleTop + visibleHeight
        
        let margin: CGFloat = 20
        let caretTop = caretRectInContentView.minY - margin
        let caretBottom = caretRectInContentView.maxY + margin
        
        var targetOffsetY: CGFloat? = nil
        
        if caretBottom > visibleBottom {
            targetOffsetY = caretBottom - visibleHeight - topInset
        } else if caretTop < visibleTop {
            targetOffsetY = caretTop - topInset
        }
        
        if let offsetY = targetOffsetY {
            let maxOffsetY = max(0, scrollView.contentSize.height - scrollView.frame.height + scrollView.contentInset.bottom)
            let minOffsetY = -topInset
            let clampedOffsetY = max(minOffsetY, min(maxOffsetY, offsetY))
            
            scrollView.setContentOffset(CGPoint(x: 0, y: clampedOffsetY), animated: true)
        }
    }
}

// MARK: - UIScrollViewDelegate

extension TodoEditorViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateBlurEffect()
    }
}

// MARK: - UIPresentationController

extension TodoEditorViewController: UIAdaptivePresentationControllerDelegate {
    
    func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
        let allows = presenter?.allowsDismissing() ?? true
        if !allows {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                self?.presentWarningAlert()
            }
        }
        return allows
    }
}
