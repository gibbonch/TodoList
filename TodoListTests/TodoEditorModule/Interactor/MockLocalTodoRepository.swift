import Foundation
import Combine
@testable import Todo_List

final class MockLocalTodoRepository: LocalTodoRepositoryProtocol {
    
    var fetchedResults: AnyPublisher<[Todo], Never> {
        fetchedResultsSubject.eraseToAnyPublisher()
    }
    
    var fetchedResultsSubject = PassthroughSubject<[Todo], Never>()
    
    var fetchTodoCalledWith: UUID?
    var updateTodoCalledWith: Todo?
    var saveTodoCalledWith: Todo?
    var fetchTodoResult: Result<Todo, Error>?
    
    func fetchTodo(by id: UUID, completion: @escaping (Result<Todo, Error>) -> Void) {
        fetchTodoCalledWith = id
        if let result = fetchTodoResult {
            completion(result)
        }
    }
    
    func fetchAllTodos(completion: @escaping (Result<[Todo], Error>) -> Void) {}
    func fetchTodos(query: String) {}
    func saveTodo(_ todo: Todo, completion: ((Result<Void, Error>) -> Void)?) {
        saveTodoCalledWith = todo
        completion?(.success(()))
    }
    func saveTodos(_ todos: [Todo], completion: @escaping (Result<Void, Error>) -> Void) {}
    func deleteTodo(withId id: UUID, completion: ((Result<Void, Error>) -> Void)?) {}
    func toggleTodoCompletion(withId id: UUID, completion: @escaping (Result<Void, Error>) -> Void) {}
    func updateTodo(with updatedTodo: Todo, completion: ((Result<Void, Error>) -> Void)?) {
        updateTodoCalledWith = updatedTodo
        completion?(.success(()))
    }
}
