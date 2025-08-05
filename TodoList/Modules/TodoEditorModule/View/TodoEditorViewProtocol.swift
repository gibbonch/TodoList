/// Протокол представления редактора задач.
protocol TodoEditorViewProtocol: AnyObject {
    
    /// Обновляет состояние представления.
    /// - Parameter newState: Новое состояние с данными для UI.
    func updateState(with newState: TodoEditorViewState)
}
