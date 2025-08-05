/// Протокол для передачи результатов работы интерактора обратно в презентер.
protocol TodoListInteractorOutput: AnyObject {
    
    /// Обновляет список задач.
    /// - Parameter todos: Массив задач.
    func updateTodos(_ todos: [Todo])
    
    /// Обрабатывает ошибку, возникшую при работе интерактора.
    /// - Parameter error: Ошибка, связанная с задачами.
    func handleFailure(_ error: TodoError)
}

