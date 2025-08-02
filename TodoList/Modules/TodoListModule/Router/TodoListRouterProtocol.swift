import Foundation

protocol TodoListRouterProtocol: AnyObject {
    func routeToCreateTodo()
    func routeToEditTodo(for todo: Todo)
    func routeToDetailTodo(for todo: Todo)
    func presentShareSheet(for items: [Any])
}
