@testable import Todo_List

final class MockTodoListInteractorOutput: TodoListInteractorOutput {
    
    var updatedTodos: [[Todo]] = []
    var receivedErrors: [TodoError] = []
    
    var didUpdate: (() -> Void)?
    
    func updateTodos(_ todos: [Todo]) {
        updatedTodos.append(todos)
        didUpdate?()
    }
    
    func handleFailure(_ error: TodoError) {
        receivedErrors.append(error)
    }
}

