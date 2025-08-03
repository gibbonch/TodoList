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

struct TodoBuilder {
    private var id: UUID = UUID()
    var title: String = ""
    var task: String = ""
    var isCompleted: Bool = false
    var date: Date = Date()
}
