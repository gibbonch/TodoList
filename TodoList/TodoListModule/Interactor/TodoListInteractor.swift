import Foundation

final class TodoListInteractor {
    
    // MARK: - Internal Properties
    
    weak var output: TodoListInteractorOutput?
    
    // MARK: - Private Properties
    
    private let remoteRepository: RemoteTodoRepositoryProtocol
    private let localRepository: LocalTodoRepositoryProtocol?
    private let defaults: UserDefaults
    private let key = "initialized"
    
    // MARK: - Lifecycle
    
    init(remoteRepository: RemoteTodoRepositoryProtocol,
         localRepository: LocalTodoRepositoryProtocol? = nil,
         defaults: UserDefaults = .standard) {
        self.remoteRepository = remoteRepository
        self.localRepository = localRepository
        self.defaults = defaults
    }
}

// MARK: - TodoListInteractorInput

extension TodoListInteractor: TodoListInteractorInput {
    
    func fetchTodos(skipLoading: Bool) {
        remoteRepository.fetchTodos { [weak self] result in
            switch result {
            case .success(let todos):
                self?.output?.updateTodos(todos)
            case .failure(_):
                self?.output?.handleFailure(.initialLoadingFailure)
            }
        }
    }
    
    func fetchTodos(by query: String) { }
    
    func deleteTodo(with id: UUID) { }
    
    func toggleCompletionOnTodo(with id: UUID) { }
}
