import Foundation

protocol TodoListInteractorInput: AnyObject {
    func fetchTodos(skipLoading: Bool)
    func fetchTodos(by query: String)
    func deleteTodo(with id: UUID)
    func toggleCompletionOnTodo(with id: UUID)
}

protocol TodoListInteractorOutput: AnyObject {
    func updateTodos(_ todos: [Todo])
    func handleFailure(_ error: TodoError)
}
