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
        subscribeOnValidationStatus()
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
        localRepository.saveTodo(todo) { [weak self] result in
            switch result {
            case .success():
                self?.output?.todoSaved()
            case .failure(_):
                break
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
    
    private func subscribeOnValidationStatus() {
        originator.$isValid.sink { [weak self] isValid in
            self?.output?.validationStatusChanged(isValid)
        }.store(in: &cancellables)
    }
}
