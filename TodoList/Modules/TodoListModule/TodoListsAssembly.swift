import UIKit

final class TodoListsAssembly {
    func assemble() -> UIViewController {
        let viewController = TodoListViewController()
        let presenter = TodoListPresenter()
        let router = TodoListRouter()
        let client = NetworkClient()
        let remoteRepository = RemoteTodoRepository(client: client)
        let localRepository = LocalTodoRepository()
        let interactor = TodoListInteractor(
            remoteRepository: remoteRepository,
            localRepository: localRepository
        )
        
        viewController.presenter = presenter
        presenter.view = viewController
        presenter.router = router
        presenter.interactor = interactor
        router.rootViewController = viewController
        interactor.output = presenter
        
        return viewController
    }
}
