import Foundation

final class TodoListPresenter {
    
    // MARK: - Internal Properties
    
    weak var view: TodoListViewProtocol?
    var interactor: TodoListInteractorInput?
    var router: TodoListRouterProtocol?
    
    // MARK: - Private Properties
    
    private var todos: [Todo] = []
    private let dateFormatter: DateFormatter
    
    // MARK: - Lifecycle
    
    init() {
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yy"
    }
    
    // MARK: - Private Methods
    
    private func createInitialState() -> TodoListViewState {
        TodoListViewState(
            todos: [.placeholder(), .placeholder(), .placeholder()],
            status: .loading
        )
    }
    
    private func createCurrentState() -> TodoListViewState {
        let cells = todos.map { todo in
            let date = dateFormatter.string(from: todo.date)
            let model = TodoCellModel(
                id: todo.id,
                title: todo.title,
                task: todo.task,
                date: date,
                isCompleted: todo.isCompleted
            )
            return TodoCellType.default(model)
        }
        return TodoListViewState(todos: cells, status: .tasks(todos.count))
    }
}

// MARK: - TodoListPresenterProtocol

extension TodoListPresenter: TodoListPresenterProtocol {
    
    func viewLoaded() {
        interactor?.fetchTodos(skipLoading: false)
    }
    
    func createTodoTapped() {
        router?.routeToCreateTodo()
    }
    
    func searchTextChanged(_ text: String) {
        interactor?.fetchTodos(by: text)
    }
    
    func cellSelected(at indexPath: IndexPath) {
        let target = todos[indexPath.row]
        router?.routeToDetailTodo(for: target)
    }
    
    func statusChangedOnCell(at indexPath: IndexPath) {
        let target = todos[indexPath.row]
        interactor?.toggleCompletionOnTodo(with: target.id)
    }
    
    func editActionOnCell(at indexPath: IndexPath) {
        let target = todos[indexPath.row]
        router?.routeToEditTodo(for: target)
    }
    
    func shareActionOnCell(at indexPath: IndexPath) {
        let target = todos[indexPath.row]
        let task = target.task
        router?.presentShareSheet(for: [task])
    }
    
    func deleteActionOnCell(at indexPath: IndexPath) {
        let target = todos[indexPath.row]
        interactor?.deleteTodo(with: target.id)
    }
    
    func skipLoadingTapped() {
        let initialState = createInitialState()
        view?.updateState(with: initialState)
        
        interactor?.fetchTodos(skipLoading: true)
    }
    
    func retryLoadingTapped() {
        let initialState = createInitialState()
        view?.updateState(with: initialState)
        
        interactor?.fetchTodos(skipLoading: false)
    }
}

// MARK: - TodoListInteractorOutput

extension TodoListPresenter: TodoListInteractorOutput {
    
    func updateTodos(_ todos: [Todo]) {
        self.todos = todos
        let state = createCurrentState()
        view?.updateState(with: state)
    }
    
    func handleFailure(_ error: TodoError) {
        switch error {
            
        case .initialLoadingFailure:
            let failureState = TodoListViewState(todos: [], status: .loadingFailure)
            view?.updateState(with: failureState)
        case .fetchingFailure:
            break
        case .deletingFailure:
            break
        case .editingFailure:
            break
        default:
            break
        }
    }
}
