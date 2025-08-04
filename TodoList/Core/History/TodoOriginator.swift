import Foundation
import Combine

final class TodoOriginator {
    
    // MARK: - Internal Properties
    
    var title: String {
        get { memento.title }
        set { memento.title = newValue }
    }
    
    var task: String {
        get { memento.task }
        set { memento.task = newValue }
    }
    
    var isValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !task.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private(set) var memento: TodoMemento
    
    // MARK: - Private Properties
    
    private var id: UUID
    private var isCompleted: Bool?
    
    // MARK: - Lifecycle
    
    init() {
        memento = TodoMemento(title: "", task: "")
        id = UUID()
        isCompleted = nil
    }
    
    init(todo: Todo) {
        memento = TodoMemento(title: todo.title, task: todo.task)
        id = todo.id
        isCompleted = todo.isCompleted
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
            date: Date()
        )
    }
}
