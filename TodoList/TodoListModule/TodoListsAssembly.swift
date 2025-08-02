import UIKit

final class TodoListsAssembly {
    func assemble() -> UIViewController {
        let viewController = TodoListViewController()
        let presenter = TodoListPresenter()
        let client = NetworkClient()
        let remoteRepository = RemoteTodoRepository(client: client)
        let localRepository = LocalTodoRepository()
        let interactor = TodoListInteractor(
            remoteRepository: remoteRepository,
            localRepository: localRepository
        )
//        let router = TodoListRouter()
        
        viewController.presenter = presenter
        presenter.view = viewController
        presenter.interactor = interactor
        interactor.output = presenter
        
        return viewController
    }
}
