import Foundation
import Combine

final class TodoOriginator {
    
    // MARK: - Internal Properties
    
    var title: String {
        get { memento.title }
        set {
            memento.title = newValue
            validate()
        }
    }
    
    var task: String {
        get { memento.task }
        set {
            memento.task = newValue
            validate()
        }
    }
    
    private(set) var memento: TodoMemento
    
    @Published var isValid: Bool
    
    // MARK: - Private Properties
    
    private var id: UUID
    private var isCompleted: Bool?
    private var date: Date?
    
    // MARK: - Lifecycle
    
    init() {
        memento = TodoMemento(title: "", task: "")
        id = UUID()
        isCompleted = nil
        date = nil
        isValid = false
    }
    
    init(todo: Todo) {
        memento = TodoMemento(title: todo.title, task: todo.task)
        id = todo.id
        isCompleted = todo.isCompleted
        date = todo.date
        isValid = true
    }
    
    // MARK: - Internal Methods
    
    func restore(from memento: TodoMemento) {
        title = memento.title
        task = memento.task
    }
    
    func build() -> Todo? {
        guard isValid else { return nil }
        
        return Todo(
            id: id,
            title: memento.title.trimmingCharacters(in: .whitespacesAndNewlines),
            task: memento.task.trimmingCharacters(in: .whitespacesAndNewlines),
            isCompleted: isCompleted ?? false,
            date: date ?? Date()
        )
    }
    
    // MARK: - Private Methods
    
    private func validate() {
        isValid = !memento.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !memento.task.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
