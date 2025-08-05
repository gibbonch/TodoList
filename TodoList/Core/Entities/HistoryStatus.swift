/// Статус истории изменений для функций отмены/повтора.
struct HistoryStatus {
    
    /// Пуста ли история изменений.
    var isEmpty: Bool = true
    
    /// Доступен ли повтор действия.
    var isRedoAvailable: Bool = false
    
    /// Доступна ли отмена действия.
    var isUndoAvailable: Bool = false
}
