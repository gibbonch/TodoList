import Foundation
import Combine

/// Протокол для управления историей снимков состояния.
protocol TodoCaretakerProtocol {
    
    /// Издатель статуса истории изменений.
    var status: AnyPublisher<HistoryStatus, Never> { get }
    
    /// Создает резервную копию текущего состояния.
    func backup()
    
    /// Отменяет последнее изменение.
    func undo()
    
    /// Повторяет отмененное изменение.
    func redo()
}

final class TodoCaretaker: TodoCaretakerProtocol {
    
    // MARK: - Internal Properties
    
    var status: AnyPublisher<HistoryStatus, Never> {
        _status.eraseToAnyPublisher()
    }
    
    // MARK: - Private Properties
    
    private var mementos: [TodoMemento] = []
    private var pointer: Int = 0
    private let originator: TodoOriginatorProtocol
    
    private let _status = CurrentValueSubject<HistoryStatus, Never>(HistoryStatus())
    
    // MARK: - Lifecycle
    
    init(originator: TodoOriginatorProtocol) {
        self.originator = originator
    }
    
    // MARK: - Internal Methods
    
    func backup() {
        if pointer < mementos.count - 1 {
            mementos = Array(mementos[0...pointer])
        }
        
        mementos.append(originator.memento)
        pointer = mementos.count - 1
        
        let historyStatus = HistoryStatus(
            isEmpty: mementos.count <= 1,
            isRedoAvailable: false,
            isUndoAvailable: pointer > 0
        )
        _status.value = historyStatus
    }
    
    func undo() {
        guard pointer > 0 else { return }
        pointer -= 1
        originator.restore(from: mementos[pointer])
        
        let historyStatus = HistoryStatus(
            isEmpty: false,
            isRedoAvailable: pointer < mementos.count - 1,
            isUndoAvailable: pointer > 0
        )
        _status.value = historyStatus
    }
    
    func redo() {
        guard pointer < mementos.count - 1 else { return }
        pointer += 1
        originator.restore(from: mementos[pointer])
        
        let historyStatus = HistoryStatus(
            isEmpty: false,
            isRedoAvailable: pointer < mementos.count - 1,
            isUndoAvailable: pointer > 0
        )
        _status.value = historyStatus
    }
}
