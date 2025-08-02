/// Протокол для управления отображением списка задач.
protocol TodoListViewProtocol: AnyObject {
    
    /// Обновляет пользовательский интерфейс в соответствии с новым состоянием.
    /// - Parameter newState: Новое состояние экрана со списком задач.
    func updateState(with newState: TodoListViewState)
}
