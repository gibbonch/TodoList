import Foundation

final class TodoDetailPresenter {
    
    // MARK: - Internal Properties
    
    weak var view: TodoDetailViewProtocol?
    
    // MARK: - Private Properties
    
    private var todo: Todo
    private let dateFormatter: DateFormatter
    
    // MARK: - Lifecycle
    
    init(todo: Todo) {
        self.todo = todo
        self.dateFormatter = DateFormatter()
        self.dateFormatter.dateFormat = "dd/MM/yy"
    }
}

// MARK: - TodoDetailPresenterProtocol

extension TodoDetailPresenter: TodoDetailPresenterProtocol {
    
    func viewLoaded() {
        let state = TodoDetailViewState(
            title: todo.title,
            task: todo.task,
            date: dateFormatter.string(from: todo.date)
        )
        view?.updateState(with: state)
    }
}
