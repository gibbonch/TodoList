import Foundation

/// Обертка для коллекциии задач.
struct TodosScheme: Decodable {
    
    /// Коллекция задач.
    let todos: [TodoScheme]
}
