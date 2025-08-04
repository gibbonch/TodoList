import UIKit

final class TodoEditorAssembly {
    
    func assembleEditScene(with todo: Todo) -> UIViewController {
        let viewController = TodoEditorViewController()
        let presenter = TodoEditorPresenter(todo: todo)
        let originator = TodoOriginator(todo: todo)
        let caretaker = TodoCaretaker(originator: originator)
        let repository = LocalTodoRepository()
        let interactor = TodoEditorInteractor(
            localRepository: repository,
            caretaker: caretaker,
            originator: originator
        )
        
        viewController.presenter = presenter
        presenter.view = viewController
        presenter.interactor = interactor
        interactor.output = presenter
        
        return viewController
    }
    
    func assembleCreateScene() -> UIViewController {
        let viewController = TodoEditorViewController()
        let presenter = TodoEditorPresenter()
        let originator = TodoOriginator()
        let caretaker = TodoCaretaker(originator: originator)
        let repository = LocalTodoRepository()
        let interactor = TodoEditorInteractor(
            localRepository: repository,
            caretaker: caretaker,
            originator: originator
        )
        
        viewController.presenter = presenter
        presenter.view = viewController
        presenter.interactor = interactor
        interactor.output = presenter
        
        return viewController
    }
}

