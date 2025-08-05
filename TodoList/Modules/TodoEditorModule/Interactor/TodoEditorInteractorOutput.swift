/// Протокол для получения данных от интерактора редактора задач.
protocol TodoEditorInteractorOutput: AnyObject {
    
    /// Вызывается при изменении данных задачи.
    /// - Parameters:
    ///   - title: Новый заголовок задачи.
    ///   - task: Новое описание задачи.
    func todoChanged(title: String, task: String)
    
    /// Вызывается при изменении статуса истории изменений.
    /// - Parameter status: Текущий статус возможности отмены/повтора действий.
    func historyStatusChanged(_ status: HistoryStatus)
}
