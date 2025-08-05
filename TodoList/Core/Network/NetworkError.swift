import Foundation

/// Ошибки сетевого взаимодействия.
enum NetworkError: Error {
    
    /// Ошибка HTTP статус кода.
    case httpStatusCode(Int)
    
    /// Ошибка при создании URL запроса.
    case urlRequestError(Error)
    
    /// Ошибка сессии URL.
    case urlSessionError
    
    /// Ошибка декодирования данных.
    case decodingError
    
    /// Недействительный URL.
    case invalidURL
}
