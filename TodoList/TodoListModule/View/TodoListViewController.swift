import UIKit

final class TodoListViewController: UIViewController {
    
    // MARK: - Internal Properties
    
    var presenter: TodoListPresenterProtocol?
    
    // MARK: - Private Properties
    
    private var currentState = TodoListViewState()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(TodoCell.self, forCellReuseIdentifier: TodoCell.reuseIdentifier)
        tableView.register(TodoPlaceholderCell.self, forCellReuseIdentifier: TodoPlaceholderCell.reuseIdentifier)
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.contentInset = .init(top: 0, left: 0, bottom: 49, right: 0)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private lazy var searchController: UISearchController = {
        let searchController = UISearchController()
        searchController.searchBar.tintColor = .yellowAsset
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = true
        searchController.automaticallyShowsCancelButton = true
        searchController.searchBar.searchBarStyle = .minimal
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
        presenter?.viewLoaded()
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
        view.addGestureRecognizer(tap)
    }
    
    private func updateUI() {
        tableView.reloadData()
        
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
        currentState = newState
        
        DispatchQueue.main.async { [weak self] in
            self?.updateUI()
        }
    }
}

// MARK: - UITableViewDataSource

extension TodoListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        currentState.todos.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellType = currentState.todos[indexPath.row]
        
        switch cellType {
        case .placeholder:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: TodoPlaceholderCell.reuseIdentifier),
                  let placeholderCell = cell as? TodoPlaceholderCell else {
                return UITableViewCell()
            }
            placeholderCell.selectionStyle = .none
            if indexPath.row == currentState.todos.count - 1 {
                placeholderCell.hideSeparator()
            }
            return placeholderCell
            
        case .default(let model):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: TodoCell.reuseIdentifier),
                  let defaultCell = cell as? TodoCell else {
                return UITableViewCell()
            }
            defaultCell.selectionStyle = .none
            if indexPath.row == currentState.todos.count - 1 {
                defaultCell.hideSeparator()
            }
            defaultCell.configure(with: model)
            return defaultCell
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
        90.0
    }
}
