import UIKit

final class TodoDetailAssembly {
    
    func assemble(with todo: Todo) -> UIViewController {
        let viewController = TodoDetailViewController()
        let presenter = TodoDetailPresenter(todo: todo)
        
        viewController.presenter = presenter
        presenter.view = viewController
        
        return viewController
    }
}
