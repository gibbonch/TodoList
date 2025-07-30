import UIKit

final class TodoListViewController: UIViewController {
    
    // MARK: - Internal Properties
    
    var presenter: TodoListPresenterProtocol?
    
    // MARK: - Private Properties
    
    private var currentState = TodoListViewState()
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupNavigationBar()
        setupConstraints()
        presenter?.viewLoaded()
    }
    
    // MARK: - Private Methods
    
    private func setupView() {
        view.backgroundColor = .red
    }
    
    private func setupNavigationBar() {
        
    }
    
    private func setupConstraints() {
        
    }
    
    private func updateUI() {
        
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
        <#code#>
    }
}

// MARK: - UITableViewDelegate

extension TodoListViewController: UITableViewDelegate { }
