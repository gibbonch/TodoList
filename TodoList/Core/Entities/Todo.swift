import Foundation

/// Модель задачи в списке дел.
struct Todo {
    
    /// Уникальный идентификатор задачи.
    let id: UUID
    
    /// Заголовок задачи.
    let title: String
    
    /// Описание задачи.
    let task: String
    
    /// Статус выполнения задачи.
    let isCompleted: Bool
    
    /// Дата создания задачи.
    let date: Date
}
