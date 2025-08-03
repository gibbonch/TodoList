import Foundation

protocol TodoDetailViewProtocol: AnyObject {
    
    func updateState(with newState: TodoDetailViewState)
}
