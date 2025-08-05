import Foundation
import Combine

/// Протокол локального хранилища задач.
protocol LocalTodoRepositoryProtocol {
    
    /// Поток задач, отслеживающий изменения.
    var fetchedResults: AnyPublisher<[Todo], Never> { get }
    
    /// Получает задачу по идентификатору.
    /// - Parameters:
    ///   - id: Уникальный идентификатор задачи.
    ///   - completion: Замыкание с результатом задачи или ошибкой.
    func fetchTodo(by id: UUID, completion: @escaping (Result<Todo, Error>) -> Void)
    
    /// Загружает все задачи.
    /// - Parameter completion: Замыкание с результатом списка задач или ошибкой.
    func fetchAllTodos(completion: @escaping (Result<[Todo], Error>) -> Void)
    
    /// Выполняет поиск задач по строке запроса.
    /// - Parameter query: Строка поиска.
    func fetchTodos(query: String)
    
    /// Сохраняет одну задачу.
    /// - Parameters:
    ///   - todo: Задача для сохранения.
    ///   - completion: Необязательное замыкание с результатом.
    func saveTodo(_ todo: Todo, completion: ((Result<Void, Error>) -> Void)?)
    
    /// Сохраняет несколько задач.
    /// - Parameters:
    ///   - todos: Список задач.
    ///   - completion: Замыкание с результатом сохранения.
    func saveTodos(_ todos: [Todo], completion: @escaping (Result<Void, Error>) -> Void)
    
    /// Удаляет задачу по идентификатору.
    /// - Parameters:
    ///   - id: Идентификатор задачи.
    ///   - completion: Необязательное замыкание с результатом удаления.
    func deleteTodo(withId id: UUID, completion: ((Result<Void, Error>) -> Void)?)
    
    /// Переключает статус выполнения задачи.
    /// - Parameters:
    ///   - id: Идентификатор задачи.
    ///   - completion: Замыкание с результатом обновления.
    func toggleTodoCompletion(withId id: UUID, completion: @escaping (Result<Void, Error>) -> Void)
    
    /// Обновляет существующую задачу.
    /// - Parameters:
    ///   - updatedTodo: Обновлённая задача.
    ///   - completion: Необязательное замыкание с результатом.
    func updateTodo(with updatedTodo: Todo, completion: ((Result<Void, Error>) -> Void)?)
}
