import UIKit

final class TodoListRouter: TodoListRouterProtocol {
    
    // MARK: - Internal Properties
    
    weak var rootViewController: UIViewController?
    
    // MARK: - Internal Methods
    
    func routeToCreateTodo() {
        let vc = TodoEditorAssembly().assembleCreateScene()
        rootViewController?.navigationController?.pushViewController(vc, animated: true)
    }
    
    func routeToEditTodo(for todo: Todo) {
        let vc = TodoEditorAssembly().assembleEditScene(with: todo)
        rootViewController?.navigationController?.pushViewController(vc, animated: true)
    }
    
    func routeToDetailTodo(for todo: Todo) {
        let vc = TodoDetailAssembly().assemble(with: todo)
        rootViewController?.navigationController?.pushViewController(vc, animated: true)
    }
    
    func presentShareSheet(for items: [Any]) {
        let vc = UIActivityViewController(activityItems: items, applicationActivities: nil)
        rootViewController?.present(vc, animated: true)
    }
}
