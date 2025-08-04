/// Структура, представляющая состояние экрана со списком задач.
struct TodoListViewState {
    
    /// Массив задач для отображения.
    var todos: [TodoCellType] = [.placeholder(), .placeholder(), .placeholder()]
    
    /// Статус экрана.
    var status: StatusViewState = .loading
}
