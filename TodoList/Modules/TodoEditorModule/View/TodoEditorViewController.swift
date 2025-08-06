import UIKit
import Combine

final class TodoEditorViewController: UIViewController {
    
    // MARK: - Internal Properties
    
    var presenter: TodoEditorPresenterProtocol?
    
    // MARK: - Private Properties
    
    private let titleSubject: PassthroughSubject<String, Never> = .init()
    private let taskSubject: PassthroughSubject<String, Never> = .init()
    private var cancellables: Set<AnyCancellable> = []
    
    private var isEditButtonVisible: Bool = false
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delaysContentTouches = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private lazy var titleTextField: UITextField = {
        let textField = UITextField()
        textField.delegate = self
        textField.textColor = .whiteAsset
        textField.font = .systemFont(ofSize: 34, weight: .bold)
        textField.attributedPlaceholder = NSAttributedString(
            string: Constants.titlePlaceholder,
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGrayAsset]
        )
        textField.tintColor = .yellowAsset
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGrayAsset
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var taskTextView: UITextView = {
        let textView = UITextView()
        textView.delegate = self
        textView.backgroundColor = .clear
        textView.textColor = .whiteAsset
        textView.font = .systemFont(ofSize: 16)
        textView.tintColor = .yellowAsset
        textView.isScrollEnabled = false
        textView.textContainer.lineFragmentPadding = 0
        textView.textContainerInset = UIEdgeInsets.zero
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    private var taskTextViewHeightConstraint: NSLayoutConstraint?
    
    private lazy var taskPlaceholderLabel: UILabel = {
        let label = UILabel()
        label.text = Constants.taskPlaceholder
        label.font = .systemFont(ofSize: 16)
        label.textColor = .lightGrayAsset
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var doneButton: UIBarButtonItem = {
        let button = UIBarButtonItem(
            title: Constants.done,
            style: .plain,
            target: self,
            action: #selector(doneButtonTapped)
        )
        return button
    }()
    
    private lazy var redoButton: UIBarButtonItem = {
        let image = UIImage.redoAsset
            .scaled(size: CGSize(width: 20, height: 20))
            .withRenderingMode(.alwaysTemplate)
        let button = UIBarButtonItem(
            image: image,
            style: .plain,
            target: self,
            action: #selector(redoButtonTapped)
        )
        return button
    }()
    
    private lazy var undoButton: UIBarButtonItem = {
        let image = UIImage.undoAsset
            .scaled(size: CGSize(width: 20, height: 20))
            .withRenderingMode(.alwaysTemplate)
        let button = UIBarButtonItem(
            image: image,
            style: .plain,
            target: self,
            action: #selector(undoButtonTapped)
        )
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupNavigationBar()
        setupConstraints()
        setupBindings()
        presenter?.viewLoaded()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        presenter?.viewWillDisappear()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let safeAreaTop = view.safeAreaInsets.top
        let safeAreaBottom = view.safeAreaInsets.bottom
        
        // Рассчитываем высоты на основе шрифтов
        let titleFieldHeight = titleTextField.font?.lineHeight ?? 44
        let dateLabelHeight = dateLabel.font?.lineHeight ?? 16
        
        let topPadding: CGFloat = 8
        let titleDateSpacing: CGFloat = 8
        let dateTaskSpacing: CGFloat = 16
        let bottomPadding: CGFloat = 20
        
        let totalVerticalSpacing = safeAreaTop + topPadding + titleFieldHeight + titleDateSpacing + dateLabelHeight + dateTaskSpacing + bottomPadding + safeAreaBottom
        
        let availableHeight = view.bounds.height - totalVerticalSpacing
        let minimumHeight: CGFloat = 200
        
        taskTextViewHeightConstraint?.constant = max(availableHeight, minimumHeight)
    }

    // MARK: - Private Methods
    
    private func setupView() {
        view.backgroundColor = .blackAsset
        contentView.addSubview(titleTextField)
        contentView.addSubview(dateLabel)
        contentView.addSubview(taskTextView)
        contentView.addSubview(taskPlaceholderLabel)
        scrollView.addSubview(contentView)
        view.addSubview(scrollView)
    }
    
    private func setupNavigationBar() {
        navigationController?.navigationBar.tintColor = .yellowAsset
        navigationItem.largeTitleDisplayMode = .never
    }
    
    private func setupConstraints() {
        taskTextViewHeightConstraint = taskTextView.heightAnchor.constraint(greaterThanOrEqualToConstant: 100)
        taskTextViewHeightConstraint?.isActive = true
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            titleTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            titleTextField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            
            dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            dateLabel.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 8),
            
            taskTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            taskTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            taskTextView.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 16),
            taskTextView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            
            taskPlaceholderLabel.leadingAnchor.constraint(equalTo: taskTextView.leadingAnchor, constant: 1),
            taskPlaceholderLabel.trailingAnchor.constraint(equalTo: taskTextView.trailingAnchor, constant: -20),
            taskPlaceholderLabel.topAnchor.constraint(equalTo: taskTextView.topAnchor),
        ])
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
        
        NotificationCenter.default
            .publisher(for: UIResponder.keyboardWillShowNotification)
            .sink { [weak self] notification in
                guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
                let keyboardHeight = keyboardFrame.cgRectValue.height
                
                self?.scrollView.contentInset.bottom = keyboardHeight + 10
                self?.scrollView.verticalScrollIndicatorInsets.bottom = keyboardHeight + 10
            }
            .store(in: &cancellables)
        
        NotificationCenter.default
            .publisher(for: UIResponder.keyboardWillHideNotification)
            .sink { [weak self] notification in
                self?.scrollView.contentInset.bottom = 10
                self?.scrollView.verticalScrollIndicatorInsets.bottom = 10
            }
            .store(in: &cancellables)
    }
    
    private func showDoneButton() {
        if navigationItem.rightBarButtonItems?.last !== doneButton {
            var items = navigationItem.rightBarButtonItems ?? []
            items.insert(doneButton, at: 0)
            navigationItem.setRightBarButtonItems(items, animated: true)
            isEditButtonVisible = true
        }
    }
    
    private func updateUI(with newState: TodoEditorViewState) {
        titleTextField.text = newState.title
        dateLabel.text = newState.date
        taskTextView.text = newState.task
        taskPlaceholderLabel.isHidden = !newState.task.isEmpty
        
        if newState.historyStatus.isEmpty {
            let items = isEditButtonVisible ? [doneButton] : []
            navigationItem.setRightBarButtonItems(items, animated: true)
        } else {
            undoButton.isEnabled = newState.historyStatus.isUndoAvailable
            redoButton.isEnabled = newState.historyStatus.isRedoAvailable
            let items = isEditButtonVisible ? [doneButton, redoButton, undoButton] : [redoButton, undoButton]
            navigationItem.setRightBarButtonItems(items, animated: true)
        }
    }
    
    @objc private func doneButtonTapped() {
        view.endEditing(true)
        var items = navigationItem.rightBarButtonItems ?? []
        items.removeFirst()
        navigationItem.setRightBarButtonItems(items, animated: true)
        isEditButtonVisible = false
    }
    
    @objc private func redoButtonTapped() {
        presenter?.redoTapped()
    }
    
    @objc private func undoButtonTapped() {
        presenter?.undoTapped()
    }
}

// MARK: - TodoEditorViewProtocol

extension TodoEditorViewController: TodoEditorViewProtocol {
    
    func updateState(with newState: TodoEditorViewState) {
        DispatchQueue.main.async { [weak self] in
            self?.updateUI(with: newState)
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
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        showDoneButton()
    }
}

// MARK: - UITextViewDelegate

extension TodoEditorViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        taskPlaceholderLabel.isHidden = !textView.text.isEmpty
        taskSubject.send(textView.text ?? "")
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        showDoneButton()
    }
    
    func textView(_ textView: UITextView,
                  shouldChangeTextIn range: NSRange,
                  replacementText text: String) -> Bool {
        
        if text == "\n" {
            let currentText = textView.text ?? ""
            
            let nsString = currentText as NSString
            let newText = nsString.replacingCharacters(in: range, with: text)
            
            textView.text = newText
            taskSubject.send(textView.text ?? "")
            
            let currentLocation = range.location + 1
            let newRange = NSRange(location: currentLocation, length: 0)
            textView.selectedRange = newRange
            
            textViewDidChange(textView)
            
            return false
        }
        
        if text.isEmpty && range.length == 1 {
            let currentText = textView.text ?? ""
            let startIndex = currentText.index(currentText.startIndex, offsetBy: range.location)
            
            if range.location < currentText.count {
                let characterToDelete = currentText[startIndex]
                
                if characterToDelete != "\n" {
                    DispatchQueue.main.async {
                        let newRange = NSRange(location: range.location, length: 0)
                        textView.selectedRange = newRange
                    }
                }
            }
        }
        
        return true
    }
}
