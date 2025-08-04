import Foundation

final class TodoEditorPresenter {
    
    // MARK: - Internal Properties
    
    weak var view: TodoEditorViewProtocol?
    var interactor: TodoEditorInteractorInput?
    
    // MARK: - Private Properties
    
    private var currentState: TodoEditorViewState
    private let title: String
    
    private let initialTitle: String
    private let initialTask: String
    
    // MARK: - Lifecycle
    
    init() {
        currentState = TodoEditorViewState()
        title = Constants.newTask
        initialTitle = ""
        initialTask = ""
    }
    
    init(todo: Todo) {
        currentState = TodoEditorViewState()
        currentState.title = todo.title
        currentState.task = todo.task
        currentState.isValid = true
        title = Constants.edit
        initialTitle = todo.title
        initialTask = todo.task
    }
}

// MARK: - TodoEditorPresenterProtocol

extension TodoEditorPresenter: TodoEditorPresenterProtocol {
    
    func viewLoaded() {
        view?.setTitle(title)
        view?.updateState(with: currentState)
    }
    
    func titleChanged(_ title: String) {
        currentState.title = title
        interactor?.updateTitle(title)
    }
    
    func taskChanged(_ task: String) {
        currentState.task = task
        interactor?.updateTask(task)
    }
    
    func saveTapped() {
        interactor?.saveTask()
    }
    
    func previousTapped() {
        interactor?.moveToPreviousSnapshot()
    }
    
    func nextTapped() {
        interactor?.moveToNextSnapshot()
    }
    
    func allowsDismissing() -> Bool {
        initialTitle == currentState.title && initialTask == currentState.task
    }
}

// MARK: - TodoEditorInteractorOutput

extension TodoEditorPresenter: TodoEditorInteractorOutput {
    
    func validationStatusChanged(_ isValid: Bool) {
        currentState.isValid = isValid
        view?.updateState(with: currentState)
    }
    
    func todoChanged(title: String, task: String) {
        currentState.title = title
        currentState.task = task
        view?.updateState(with: currentState)
    }
    
    func historyStatusChanged(_ status: HistoryStatus) {
        let headerViewState = HeaderViewState(
            isHistoryVisible: !status.isEmpty,
            hasPreviousState: status.hasPrevious,
            hasNextState: status.hasNext
        )
        currentState.headerViewState = headerViewState
        
        view?.updateState(with: currentState)
    }
    
    func todoSaved() { view?.dismiss() }
}
