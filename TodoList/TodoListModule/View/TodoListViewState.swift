/// Структура, представляющая состояние экрана со списком задач.
struct TodoListViewState {
    
    /// Массив задач для отображения.
    var todos: [TodoCellType] = []
    
    /// Статус экрана.
    var status: StatusViewState = .loading
}
