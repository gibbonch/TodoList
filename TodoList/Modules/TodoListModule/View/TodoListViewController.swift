import UIKit
import Combine
import Speech
import AVFoundation

final class TodoListViewController: UIViewController {
    
    // MARK: - Internal Properties
    
    var presenter: TodoListPresenterProtocol?
    
    // MARK: - Private Properties
    
    private var currentState = TodoListViewState()
    private var cancellables: Set<AnyCancellable> = []
    
    private let speechService = SpeechRecognizerService()

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.register(TodoCell.self, forCellReuseIdentifier: TodoCell.reuseIdentifier)
        tableView.register(TodoPlaceholderCell.self, forCellReuseIdentifier: TodoPlaceholderCell.reuseIdentifier)
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.contentInset = .init(top: 0, left: 0, bottom: 49, right: 0)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private lazy var dataSource: DataSource = {
        let datasource = DataSource(tableView: tableView) { [weak self] tableView, indexPath, cellType in
            guard let self else { return UITableViewCell() }
            
            switch cellType {
            case .placeholder:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: TodoPlaceholderCell.reuseIdentifier),
                      let placeholderCell = cell as? TodoPlaceholderCell else {
                    return UITableViewCell()
                }
                placeholderCell.selectionStyle = .none
                return placeholderCell
                
            case .default(let model):
                guard let cell = tableView.dequeueReusableCell(withIdentifier: TodoCell.reuseIdentifier),
                      let defaultCell = cell as? TodoCell else {
                    return UITableViewCell()
                }
                defaultCell.selectionStyle = .none
                defaultCell.configure(with: model)
                defaultCell.onToggleCompletion = { [weak presenter] in
                    presenter?.statusChangedOnCell(at: indexPath)
                }
                return defaultCell
            }
        }
        datasource.defaultRowAnimation = .automatic
        return datasource
    }()
    
    private lazy var searchController: UISearchController = {
        let searchController = UISearchController()
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = true
        searchController.automaticallyShowsCancelButton = true
        searchController.searchBar.placeholder = Constants.search
        searchController.searchBar.setValue(Constants.cancel, forKey: "cancelButtonText")
        
        searchController.searchBar.tintColor = .yellowAsset
        searchController.searchBar.searchBarStyle = .minimal
        searchController.searchBar.delegate = self
        
        let searchTextField = searchController.searchBar.searchTextField
        searchTextField.backgroundColor = .grayAsset
        searchTextField.textColor = .whiteAsset
        searchTextField.attributedPlaceholder = NSAttributedString(
            string: Constants.search,
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGrayAsset]
        )
        
        if let leftView = searchTextField.leftView as? UIImageView {
            leftView.image = leftView.image?.withRenderingMode(.alwaysTemplate)
            leftView.tintColor = .lightGrayAsset
        }
        
        if let clearButton = searchTextField.value(forKey: "clearButton") as? UIButton {
            clearButton.setImage(clearButton.currentImage?.withRenderingMode(.alwaysTemplate), for: .normal)
            clearButton.tintColor = .lightGrayAsset
        }
        
        if let rightView = searchTextField.rightView {
            rightView.tintColor = .lightGrayAsset
        }
        
        let micImage = UIImage.micAsset
            .scaled(size: .init(width: 15, height: 22))
            .withRenderingMode(.alwaysTemplate)
        searchController.searchBar.setImage(micImage, for: .bookmark, state: .normal)
        searchController.searchBar.showsBookmarkButton = true
        
        searchController.searchBar.delegate = self
        searchController.searchBar.searchTextField.delegate = self
        
        return searchController
    }()
    
    private lazy var statusView: StatusView = {
        let view = StatusView()
        view.onButtonTap = { [weak presenter] in
            presenter?.createTodoTapped()
        }
        view.tintColor = .yellowAsset
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var loadingFailureView: LoadingFailureView = {
        let view = LoadingFailureView()
        view.onRetryTap = { [weak presenter] in
            presenter?.retryLoadingTapped()
        }
        view.onSkipTap = { [weak presenter] in
            presenter?.skipLoadingTapped()
        }
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupNavigationBar()
        setupConstraints()
        setupGestures()
        subscribeOnKeyboardState()
        speechService.delegate = self
        applySnapshot(animated: false)
        presenter?.viewLoaded()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        speechService.stopRecording()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        searchController.searchBar.searchTextField.textColor = .whiteAsset
        searchController.searchBar.searchTextField.backgroundColor = .grayAsset
        if let rightView = searchController.searchBar.searchTextField.rightView {
            rightView.tintColor = .lightGrayAsset
        }
    }
    
    // MARK: - Private Methods
    
    private func setupView() {
        view.backgroundColor = .blackAsset
        view.addSubview(tableView)
        view.addSubview(statusView)
        view.addSubview(loadingFailureView)
    }
    
    private func setupNavigationBar() {
        title = Constants.title
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        let backItem = UIBarButtonItem()
        backItem.title = Constants.backward
        navigationItem.backBarButtonItem = backItem
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            statusView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -49),
            statusView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            statusView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            statusView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            loadingFailureView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 44),
            loadingFailureView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -44),
            loadingFailureView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
    
    private func setupGestures() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    private func subscribeOnKeyboardState() {
        NotificationCenter.default
            .publisher(for: UIResponder.keyboardWillShowNotification)
            .sink { [weak self] notification in
                guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
                let keyboardHeight = keyboardFrame.cgRectValue.height
                
                self?.tableView.contentInset.bottom = keyboardHeight + 10
                self?.tableView.verticalScrollIndicatorInsets.bottom = keyboardHeight + 10
            }
            .store(in: &cancellables)
        
        NotificationCenter.default
            .publisher(for: UIResponder.keyboardWillHideNotification)
            .sink { [weak self] notification in
                self?.tableView.contentInset.bottom = 49
                self?.tableView.verticalScrollIndicatorInsets.bottom = 49
            }
            .store(in: &cancellables)
    }
    
    private func updateUI() {
        DispatchQueue.main.async { [weak self] in
            self?.updateBlurEffect()
        }
        
        switch currentState.status {
        case .loading:
            statusView.isUserInteractionEnabled = false
            tableView.isHidden = false
            loadingFailureView.isHidden = true
            statusView.updateState(with: .loading)
            searchController.searchBar.isUserInteractionEnabled = false
        case .tasks(let count):
            statusView.isUserInteractionEnabled = true
            tableView.isHidden = false
            loadingFailureView.isHidden = true
            statusView.updateState(with: .tasks(count))
            searchController.searchBar.isUserInteractionEnabled = true
        case .loadingFailure:
            statusView.isUserInteractionEnabled = false
            tableView.isHidden = true
            loadingFailureView.isHidden = false
            statusView.updateState(with: .loadingFailure)
            searchController.searchBar.isUserInteractionEnabled = false
        }
    }
    
    private func applySnapshot(animated: Bool) {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(currentState.todos)
        dataSource.apply(snapshot, animatingDifferences: animated)
    }
    
    private func updateBlurEffect() {
        let offsetY = tableView.contentOffset.y
        let contentHeight = tableView.contentSize.height + 49
        let visibleHeight = tableView.frame.size.height
        
        let distanceToBottom = contentHeight - offsetY - visibleHeight
        
        let fadeThreshold: CGFloat = 5
        let alpha = min(1, max(0, distanceToBottom / fadeThreshold))
        
        statusView.setBlurAlpha(alpha)
    }
    
    @objc private func hideKeyboard() {
        if searchController.searchBar.text?.isEmpty ?? true {
            searchController.searchBar.resignFirstResponder()
            searchController.isActive = false
        } else {
            searchController.searchBar.resignFirstResponder()
        }
    }
}

// MARK: - TodoListViewProtocol

extension TodoListViewController: TodoListViewProtocol {
    
    func updateState(with newState: TodoListViewState) {
        DispatchQueue.main.async { [weak self] in
            let statusChanged = self?.currentState.status != newState.status
            self?.currentState = newState
            self?.applySnapshot(animated: !statusChanged)
            self?.updateUI()
        }
    }
}

// MARK: - UITableViewDelegate

extension TodoListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView,
                   estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        84.0
    }
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        guard case .default(_) = currentState.todos[indexPath.row] else {
            return
        }
        presenter?.cellSelected(at: indexPath)
    }
    
    func tableView(_ tableView: UITableView,
                   contextMenuConfigurationForRowAt indexPath: IndexPath,
                   point: CGPoint) -> UIContextMenuConfiguration? {
        
        UIContextMenuConfiguration(
            identifier: nil,
            previewProvider: { [weak self] in
                guard case .default(let model) = self?.currentState.todos[indexPath.row] else {
                    return UIViewController()
                }
                
                guard let cell = tableView.cellForRow(at: indexPath) else {
                    return UIViewController()
                }
                
                let previewVC = TodoPreviewViewController(todo: model)
                previewVC.preferredContentSize = cell.bounds.size
                return previewVC
            },
            actionProvider: { [weak self] suggestedActions in
                guard case .default(_) = self?.currentState.todos[indexPath.row] else {
                    return nil
                }
                
                let editAction = UIAction(title: Constants.edit,
                                          image: .editAsset) { [weak self] _ in
                    self?.presenter?.editActionOnCell(at: indexPath)
                }
                
                let shareAction = UIAction(title: Constants.share,
                                           image: .shareAsset) { [weak self] _ in
                    self?.presenter?.shareActionOnCell(at: indexPath)
                }
                
                let deleteAction = UIAction(title: Constants.delete,
                                            image: .trashAsset,
                                            attributes: .destructive) { [weak self] _ in
                    // Необходима задержка, чтобы превью успело закрыться
                    // Без этого баг анимации
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                        self?.presenter?.deleteActionOnCell(at: indexPath)
                    }
                }
                
                return UIMenu(children: [editAction, shareAction, deleteAction])
            }
        )
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateBlurEffect()
    }
}

// MARK: - UISearchBarDelegate

extension TodoListViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        presenter?.searchTextChanged(searchText)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        presenter?.searchTextChanged("")
    }
    
    // MARK: Voice Input
    
    func searchBarBookmarkButtonClicked(_ searchBar: UISearchBar) {
        #if !targetEnvironment(simulator)
        searchController.searchBar.searchTextField.resignFirstResponder()
        speechService.toggleRecording()
        #endif
    }
    
    private func updateMicButton(isListening: Bool) {
        let image = isListening ? UIImage.clearAsset : UIImage.micAsset
        let scaled = image.scaled(size: .init(width: 15, height: isListening ? 15 : 22))
        let tinted = scaled.withRenderingMode(.alwaysTemplate)
        
        searchController.searchBar.setImage(tinted, for: .bookmark, state: .normal)
    }
}

// MARK: - UITextFieldDelegate

extension TodoListViewController: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return !speechService.isRecording
    }
}

// MARK: - SpeechRecognizerServiceDelegate

extension TodoListViewController: SpeechRecognizerServiceDelegate {
    
    func speechRecognizerDidReceive(transcription: String) {
        searchController.searchBar.searchTextField.text = transcription
        searchBar(searchController.searchBar, textDidChange: transcription)
    }
    
    func speechRecognizerDidStartListening() {
        updateMicButton(isListening: true)
    }
    
    func speechRecognizerDidStopListening() {
        updateMicButton(isListening: false)
    }
}


// MARK: - Section

fileprivate enum Section {
    case main
}

// MARK: - Type Alises

fileprivate typealias DataSource = UITableViewDiffableDataSource<Section, TodoCellType>
fileprivate typealias Snapshot = NSDiffableDataSourceSnapshot<Section, TodoCellType>

