import Foundation

/// Протокол для презентера списка задач.
protocol TodoListPresenterProtocol: AnyObject {
    
    /// Вызывается после загрузки представления.
    func viewLoaded()
    
    /// Обрабатывает нажатие кнопки создания новой задачи.
    func createTodoTapped()
    
    /// Обрабатывает изменение текста в строке поиска.
    /// - Parameter text: Новый текст поиска.
    func searchTextChanged(_ text: String)
    
    /// Обрабатывает выбор ячейки списка задач.
    /// - Parameter indexPath: Индекс выбранной ячейки.
    func cellSelected(at indexPath: IndexPath)
    
    /// Обрабатывает изменение статуса задачи в ячейке.
    /// - Parameter indexPath: Индекс соответствующей ячейки.
    func statusChangedOnCell(at indexPath: IndexPath)
    
    /// Обрабатывает нажатие действия "Редактировать" на ячейке.
    /// - Parameter indexPath: Индекс соответствующей ячейки.
    func editActionOnCell(at indexPath: IndexPath)
    
    /// Обрабатывает нажатие действия "Поделиться" на ячейке.
    /// - Parameter indexPath: Индекс соответствующей ячейки.
    func shareActionOnCell(at indexPath: IndexPath)
    
    /// Обрабатывает нажатие действия "Удалить" на ячейке.
    /// - Parameter indexPath: Индекс соответствующей ячейки.
    func deleteActionOnCell(at indexPath: IndexPath)
    
    /// Обрабатывает нажатие кнопки пропуска экрана загрузки.
    func skipLoadingTapped()
    
    /// Обрабатывает нажатие кнопки повторной попытки загрузки.
    func retryLoadingTapped()
}

