/// Модель экрана редактирования задачи.
struct TodoEditorViewState {
    
    /// Название задачи.
    var title: String = ""
    /// Задача.
    var task: String = ""
    /// Дата создания. У новой задачи сегодняшняя дата. Ранее созданная задача имеет дату последнего измнения.
    var date: String = ""
    /// Статус истории для формирования `[UIBarButtonItem]`.
    var historyStatus: HistoryStatus = HistoryStatus()
}
