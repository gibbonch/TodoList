import Combine

final class TodoEditorInteractor: TodoEditorInteractorInput {
    
    // MARK: - Internal Properties
    
    weak var output: TodoEditorInteractorOutput?
    
    // MARK: - Private Properties
    
    private let localRepository: LocalTodoRepositoryProtocol
    private let caretaker: TodoCaretaker
    private let originator: TodoOriginator
    
    private var cancellables: Set<AnyCancellable> = []
    
    // MARK: - Lifecycle
    
    init(localRepository: LocalTodoRepositoryProtocol,
         caretaker: TodoCaretaker,
         originator: TodoOriginator) {
        self.localRepository = localRepository
        self.caretaker = caretaker
        self.originator = originator
        subscribeOnHistoryStatus()
        caretaker.backup()
    }
    
    // MARK: - Internal Methods
    
    func updateTitle(_ title: String) {
        originator.title = title
        caretaker.backup()
    }
    
    func updateTask(_ task: String) {
        originator.task = task
        caretaker.backup()
    }
    
    func saveTask() {
        guard let todo = originator.build() else { return }
        
        localRepository.fetchTodo(by: todo.id) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(_):
                self.localRepository.updateTodo(with: todo, completion: nil)
            case .failure(_):
                localRepository.saveTodo(todo, completion: nil)
            }
        }
    }
    
    func moveToPreviousSnapshot() {
        caretaker.previous()
        output?.todoChanged(title: originator.title, task: originator.task)
    }
    
    func moveToNextSnapshot() {
        caretaker.next()
        output?.todoChanged(title: originator.title, task: originator.task)
    }
    
    // MARK: - Private Methods
    
    private func subscribeOnHistoryStatus() {
        caretaker.$status.sink { [weak self] status in
            self?.output?.historyStatusChanged(status)
        }.store(in: &cancellables)
    }
}
