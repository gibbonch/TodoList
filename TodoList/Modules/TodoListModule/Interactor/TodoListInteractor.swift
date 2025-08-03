import Foundation

final class TodoListInteractor {
    
    // MARK: - Internal Properties
    
    weak var output: TodoListInteractorOutput?
    
    // MARK: - Private Properties
    
    private let remoteRepository: RemoteTodoRepositoryProtocol
    private let localRepository: LocalTodoRepositoryProtocol
    private let defaults: UserDefaults
    
    private let key = "initialized"
    private var lastQuery = ""
    
    // MARK: - Lifecycle
    
    init(remoteRepository: RemoteTodoRepositoryProtocol,
         localRepository: LocalTodoRepositoryProtocol,
         defaults: UserDefaults = .standard) {
        self.remoteRepository = remoteRepository
        self.localRepository = localRepository
        self.defaults = defaults
    }
    
    private func fetchTodosFromLocalRepository() {
        localRepository.fetchTodos(query: lastQuery) { [weak self] result in
            switch result {
            case .success(let todos):
                self?.output?.updateTodos(todos)
            case .failure(_):
                self?.output?.handleFailure(.fetchingFailure)
            }
        }
    }
}

// MARK: - TodoListInteractorInput

extension TodoListInteractor: TodoListInteractorInput {
    
    func fetchTodos(skipLoading: Bool) {
        if skipLoading {
            defaults.set(true, forKey: key)
        }
        
        if defaults.bool(forKey: key) {
            fetchTodosFromLocalRepository()
            return
        }
        
        remoteRepository.fetchTodos { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let todos):
                localRepository.saveTodos(todos) { result in
                    switch result {
                    case .success:
                        self.defaults.set(true, forKey: self.key)
                        self.fetchTodosFromLocalRepository()
                        
                    case .failure:
                        self.output?.handleFailure(.initialLoadingFailure)
                    }
                }
            case .failure(_):
                output?.handleFailure(.initialLoadingFailure)
            }
        }
    }
    
    func fetchTodos(by query: String) {
        lastQuery = query
        localRepository.fetchTodos(query: query) { [weak self] result in
            switch result {
            case .success(let todos):
                self?.output?.updateTodos(todos)
            case .failure(_):
                self?.output?.handleFailure(.fetchingFailure)
            }
        }
    }
    
    func deleteTodo(with id: UUID) {
        localRepository.deleteTodo(withId: id) { [weak self] result in
            switch result {
            case .success():
                self?.fetchTodosFromLocalRepository()
            case .failure(_):
                self?.output?.handleFailure(.editingFailure)
            }
        }
    }
    
    func toggleCompletionOnTodo(with id: UUID) {
        localRepository.toggleTodoCompletion(withId: id) { [weak self] result in
            switch result {
            case .success():
                self?.fetchTodosFromLocalRepository()
            case .failure(_):
                self?.output?.handleFailure(.editingFailure)
            }
        }
    }
}
