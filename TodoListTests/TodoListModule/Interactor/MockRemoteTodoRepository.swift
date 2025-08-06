import Foundation
@testable import Todo_List

final class MockRemoteTodoRepository: RemoteTodoRepositoryProtocol {
    
    var fetchTodosCalled = false
    var todosToReturn: [Todo] = []
    var errorToReturn: Error?

    func fetchTodos(completion: @escaping (Result<[Todo], Error>) -> Void) {
        fetchTodosCalled = true
        if let error = errorToReturn {
            completion(.failure(error))
        } else {
            completion(.success(todosToReturn))
        }
    }
}
