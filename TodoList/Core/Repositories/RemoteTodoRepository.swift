import Foundation

protocol RemoteTodoRepositoryProtocol {
    func fetchTodos() -> [Todo]
}

final class RemoteTodoRepository: RemoteTodoRepositoryProtocol {
    
    func fetchTodos() -> [Todo] {
        return []
    }
}
