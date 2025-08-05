import Foundation

/// Ошибки, связанные с локальным хранилищем задач.
enum LocalTodoRepositoryError: Error, LocalizedError {
    
    /// Задача не найдена.
    case todoNotFound
}
