import Foundation
import Combine
@testable import Todo_List

final class TodoListMockLocalTodoRepository: LocalTodoRepositoryProtocol {
    
    var fetchedResultsSubject = PassthroughSubject<[Todo], Never>()
    var fetchedResults: AnyPublisher<[Todo], Never> {
        fetchedResultsSubject.eraseToAnyPublisher()
    }

    var fetchTodosCalledWith: String?
    func fetchTodos(query: String) {
        fetchTodosCalledWith = query
    }

    var savedTodos: [Todo]?
    var saveTodosShouldFail = false
    func saveTodos(_ todos: [Todo], completion: @escaping (Result<Void, Error>) -> Void) {
        savedTodos = todos
        if saveTodosShouldFail {
            completion(.failure(TodoListInteractorMockError.saveFailed))
        } else {
            completion(.success(()))
        }
    }

    var deletedTodoId: UUID?
    func deleteTodo(withId id: UUID, completion: ((Result<Void, Error>) -> Void)?) {
        deletedTodoId = id
        completion?(.success(()))
    }

    var toggleCompletionCalledWith: UUID?
    var toggleShouldFail = false
    func toggleTodoCompletion(withId id: UUID, completion: @escaping (Result<Void, Error>) -> Void) {
        toggleCompletionCalledWith = id
        if toggleShouldFail {
            completion(.failure(TodoListInteractorMockError.toggleFailed))
        } else {
            completion(.success(()))
        }
    }

    func fetchTodo(by id: UUID, completion: @escaping (Result<Todo, Error>) -> Void) {}
    func fetchAllTodos(completion: @escaping (Result<[Todo], Error>) -> Void) {}
    func saveTodo(_ todo: Todo, completion: ((Result<Void, Error>) -> Void)?) {}
    func updateTodo(with updatedTodo: Todo, completion: ((Result<Void, Error>) -> Void)?) {}
}
