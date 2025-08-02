import Foundation

protocol TodoListPresenterProtocol: AnyObject {    
    func viewLoaded()
    func createTodoTapped()
    func searchTextChanged(_ text: String)
    func cellSelected(at indexPath: IndexPath)
    func statusChangedOnCell(at indexPath: IndexPath)
    func editActionOnCell(at indexPath: IndexPath)
    func shareActionOnCell(at indexPath: IndexPath)
    func deleteActionOnCell(at indexPath: IndexPath)
    func skipLoadingTapped()
    func retryLoadingTapped()
}
