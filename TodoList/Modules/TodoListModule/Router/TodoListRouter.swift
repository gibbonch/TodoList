import UIKit

final class TodoListRouter: TodoListRouterProtocol {
    
    // MARK: - Internal Properties
    
    weak var rootViewController: UIViewController?
    
    // MARK: - Internal Properties
    
    func routeToCreateTodo() {
        let vc = TodoEditorViewController()
        rootViewController?.present(vc, animated: true)
    }
    
    func routeToEditTodo(for todo: Todo) {
        let vc = TodoEditorViewController()
        rootViewController?.present(vc, animated: true)
    }
    
    func routeToDetailTodo(for todo: Todo) {
        let vc = TodoDetailViewController()
        rootViewController?.navigationController?.pushViewController(vc, animated: true)
    }
    
    func presentShareSheet(for items: [Any]) {
        let vc = UIActivityViewController(activityItems: items, applicationActivities: nil)
        rootViewController?.present(vc, animated: true)
    }
}
