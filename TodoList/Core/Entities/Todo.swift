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

/// Протокол создания модели задачи.
protocol TodoBuilderProtocol {
    
    /// Заголовок задачи.
    var title: String { get set }
    
    /// Описание задачи.
    var task: String { get set }
    
    /// Создает модель задачи на основе установленных параметров.
    /// - Returns: Созданная модель задачи или nil в случае невалидных данных.
    func build() -> Todo?
}
