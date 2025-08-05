/// Протокол для взаимодействия с интерактором редактора задач.
protocol TodoEditorInteractorInput: AnyObject {
    
    /// Обновляет заголовок задачи.
    /// - Parameter title: Новый заголовок.
    func updateTitle(_ title: String)
    
    /// Обновляет описание задачи.
    /// - Parameter task: Новое описание.
    func updateTask(_ task: String)
    
    /// Сохраняет текущее состояние задачи.
    func saveTask()
    
    /// Отменяет последнее изменение.
    func undoLastChange()
    
    /// Повторяет отмененное изменение.
    func redoLastChange()
}
