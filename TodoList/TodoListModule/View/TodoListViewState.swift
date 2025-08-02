/// Структура, представляющая состояние экрана со списком задач.
struct TodoListViewState {
    
    /// Массив задач для отображения.
    var todos: [TodoCellType] = Array(repeating: .placeholder, count: 3)
    
    /// Статус экрана.
    var status: StatusViewState = .loading
}
