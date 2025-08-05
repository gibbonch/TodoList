import Combine

final class TodoEditorInteractor: TodoEditorInteractorInput {
    
    // MARK: - Internal Properties
    
    weak var output: TodoEditorInteractorOutput?
    
    // MARK: - Private Properties
    
    private let localRepository: LocalTodoRepositoryProtocol
    private let caretaker: TodoCaretakerProtocol
    private var builder: TodoBuilderProtocol
    
    private var cancellables: Set<AnyCancellable> = []
    
    // MARK: - Lifecycle
    
    init(localRepository: LocalTodoRepositoryProtocol,
         caretaker: TodoCaretakerProtocol,
         builder: TodoBuilderProtocol) {
        self.localRepository = localRepository
        self.caretaker = caretaker
        self.builder = builder
        subscribeOnHistoryStatus()
        caretaker.backup()
    }
    
    // MARK: - Internal Methods
    
    func updateTitle(_ title: String) {
        builder.title = title
        caretaker.backup()
    }
    
    func updateTask(_ task: String) {
        builder.task = task
        caretaker.backup()
    }
    
    func saveTask() {
        guard let todo = builder.build() else { return }
        
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
    
    func undoLastChange() {
        caretaker.undo()
        output?.todoChanged(title: builder.title, task: builder.task)
    }
    
    func redoLastChange() {
        caretaker.redo()
        output?.todoChanged(title: builder.title, task: builder.task)
    }
    
    // MARK: - Private Methods
    
    private func subscribeOnHistoryStatus() {
        caretaker.status.sink { [weak self] status in
            self?.output?.historyStatusChanged(status)
        }.store(in: &cancellables)
    }
}
