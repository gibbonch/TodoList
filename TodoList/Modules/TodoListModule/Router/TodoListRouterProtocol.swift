import Foundation

/// Протокол навигации на экране списка задач.
protocol TodoListRouterProtocol: AnyObject {
    
    /// Переход на экран создание задачи.
    func routeToCreateTodo()
    
    /// Переход на экран редактирования задачи.
    /// - Parameter todo: Выбранная задача.
    func routeToEditTodo(for todo: Todo)
    
    /// Переход к детальной информации о задаче.
    /// - Parameter todo: Выбранная задача.
    func routeToDetailTodo(for todo: Todo)
    
    /// Отображение модального экрана `Поделиться`.
    /// - Parameter items: Объекты для отображения.
    func presentShareSheet(for items: [Any])
}
