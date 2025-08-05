/// Ошибки при работе с задачами.
enum TodoError: Error {
    
    /// Ошибка при первоначальной загрузке.
    case initialLoadingFailure
    
    /// Ошибка при получении данных.
    case fetchingFailure
    
    /// Ошибка при редактировании.
    case editingFailure
    
    /// Ошибка при удалении.
    case deletingFailure
    
    /// Ошибка при создании.
    case creatingFailure
}
