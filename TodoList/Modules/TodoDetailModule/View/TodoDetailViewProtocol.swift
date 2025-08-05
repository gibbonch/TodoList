/// Протокол отображения детальной информации о задаче.
protocol TodoDetailViewProtocol: AnyObject {
    
    /// Обновляет состояние отображения.
    /// - Parameter newState: Обновленное состояние.
    func updateState(with newState: TodoDetailViewState)
}
