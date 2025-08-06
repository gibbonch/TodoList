import Combine
@testable import Todo_List

final class MockCaretaker: TodoCaretakerProtocol {
    
    var backupCalled = false
    var undoCalled = false
    var redoCalled = false
    
    private let subject = CurrentValueSubject<HistoryStatus, Never>(HistoryStatus())
    
    var status: AnyPublisher<HistoryStatus, Never> {
        subject.eraseToAnyPublisher()
    }
    
    func backup() {
        backupCalled = true
    }
    
    func undo() {
        undoCalled = true
    }
    
    func redo() {
        redoCalled = true
    }
    
    func emitStatus(_ status: HistoryStatus) {
        subject.send(status)
    }
}
