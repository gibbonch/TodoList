import Foundation

/// Протокол для взаимодействия презентера со слоем бизнес-логики (интерактором) списка задач.
protocol TodoListInteractorInput: AnyObject {
    
    /// Загружает список задач.
    /// - Parameter skipLoading: Пропустить ли экран загрузки (например, при pull-to-refresh).
    func fetchTodos(skipLoading: Bool)
    
    /// Загружает задачи по поисковому запросу.
    /// - Parameter query: Строка поиска.
    func fetchTodos(by query: String)
    
    /// Удаляет задачу по идентификатору.
    /// - Parameter id: Уникальный идентификатор задачи.
    func deleteTodo(with id: UUID)
    
    /// Переключает статус завершенности задачи.
    /// - Parameter id: Уникальный идентификатор задачи.
    func toggleCompletionOnTodo(with id: UUID)
}

