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
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yy"
        currentState.date = formatter.string(from: Date())
    }
    
    init(todo: Todo) {
        currentState = TodoEditorViewState()
        currentState.title = todo.title
        currentState.task = todo.task
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yy"
        currentState.date = formatter.string(from: todo.date)
        title = Constants.edit
        initialTitle = todo.title
        initialTask = todo.task
    }
}

// MARK: - TodoEditorPresenterProtocol

extension TodoEditorPresenter: TodoEditorPresenterProtocol {
    
    func viewLoaded() {
        view?.updateState(with: currentState)
    }
    
    func viewWillDisappear() {
        interactor?.saveTask()
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
}

// MARK: - TodoEditorInteractorOutput

extension TodoEditorPresenter: TodoEditorInteractorOutput {
    
    func todoChanged(title: String, task: String) {
        currentState.title = title
        currentState.task = task
        view?.updateState(with: currentState)
    }
    
    func historyStatusChanged(_ status: HistoryStatus) {
        currentState.historyStatus = status
        view?.updateState(with: currentState)
    }
}
