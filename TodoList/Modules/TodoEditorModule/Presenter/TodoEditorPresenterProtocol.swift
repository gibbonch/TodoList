/// Протокол для презентера редактора задач.
protocol TodoEditorPresenterProtocol: AnyObject {
    
    /// Вызывается после загрузке представления.
    func viewLoaded()
    
    /// Вызывается перед исчезновением представления.
    func viewWillDisappear()
    
    /// Обрабатывает изменение заголовка задачи.
    /// - Parameter title: Новый заголовок задачи.
    func titleChanged(_ title: String)
    
    /// Обрабатывает изменение задачи.
    /// - Parameter task: Новое описание задачи.
    func taskChanged(_ task: String)
    
    /// Обрабатывает нажатие кнопки "Отменить".
    func undoTapped()
    
    /// Обрабатывает нажатие кнопки "Повторить".
    func redoTapped()
}
