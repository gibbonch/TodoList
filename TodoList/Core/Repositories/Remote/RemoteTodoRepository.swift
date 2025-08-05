import Foundation

/// Протокол для удалённого хранилища задач.
protocol RemoteTodoRepositoryProtocol {
    
    /// Загружает список задач с удалённого сервера.
    /// - Parameter completion: Замыкание с результатом: список задач или ошибка.
    func fetchTodos(completion: @escaping (Result<[Todo], any Error>) -> Void)
}

final class RemoteTodoRepository: RemoteTodoRepositoryProtocol {
    
    private let url = "https://dummyjson.com/todos"
    private let client: NetworkClientProtocol
    
    init(client: NetworkClientProtocol) {
        self.client = client
    }
    
    func fetchTodos(completion: @escaping (Result<[Todo], any Error>) -> Void) {
        client.fetchData(from: url, type: TodosScheme.self) { result in
            switch result {
            case .success(let scheme):
                let todos = scheme.todos.map { $0.mapToDomain() }
                completion(.success(todos))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
