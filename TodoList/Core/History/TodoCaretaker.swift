import Foundation
import Combine

final class TodoCaretaker {
    
    @Published var status = HistoryStatus(isEmpty: true, hasNext: false, hasPrevious: false)
    
    private var mementos: [TodoMemento] = []
    private var pointer: Int = 0
    private let originator: TodoOriginator
    
    init(originator: TodoOriginator) {
        self.originator = originator
    }
    
    func backup() {
        if pointer < mementos.count - 1 {
            mementos = Array(mementos[0...pointer])
        }
        
        mementos.append(originator.memento)
        pointer = mementos.count - 1
        
        status.isEmpty = mementos.count <= 1
        status.hasNext = false
        status.hasPrevious = pointer > 0
    }
    
    func previous() {
        guard pointer > 0 else { return }
        pointer -= 1
        originator.restore(from: mementos[pointer])
        
        status.hasPrevious = pointer > 0
        status.hasNext = pointer < mementos.count - 1
    }
    
    func next() {
        guard pointer < mementos.count - 1 else { return }
        pointer += 1
        originator.restore(from: mementos[pointer])
        
        status.hasPrevious = pointer > 0
        status.hasNext = pointer < mementos.count - 1
    }
}
