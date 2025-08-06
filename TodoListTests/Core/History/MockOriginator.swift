@testable import Todo_List

final class MockOriginator: TodoOriginatorProtocol {
    
    var memento: TodoMemento = TodoMemento(title: "", task: "")
    var restoreCallHistory: [TodoMemento] = []
    
    func restore(from memento: TodoMemento) {
        self.memento = memento
        restoreCallHistory.append(memento)
    }
}

