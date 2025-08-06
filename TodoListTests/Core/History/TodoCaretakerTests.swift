import XCTest
import Combine

@testable import Todo_List

final class TodoCaretakerTests: XCTestCase {
    
    private var sut: TodoCaretaker!
    private var originator: MockOriginator!
    private var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        originator = MockOriginator()
        sut = TodoCaretaker(originator: originator)
        cancellables = Set<AnyCancellable>()
    }
    
    override func tearDown() {
        sut = nil
        originator = nil
        cancellables = nil
        super.tearDown()
    }
    
    func testBackup_savesCurrentState() {
        // Given
        originator.memento = TodoMemento(title: "Title 1", task: "Task 1")
        
        // When
        sut.backup()
        
        originator.memento = TodoMemento(title: "Title 2", task: "Task 2")
        sut.backup()
        
        // Then
        sut.undo()
        XCTAssertEqual(originator.restoreCallHistory.last?.title, "Title 1")
        XCTAssertEqual(originator.restoreCallHistory.last?.task, "Task 1")
    }
    
    func testUndo_restoresPreviousState() {
        // Given
        originator.memento = TodoMemento(title: "A", task: "A task")
        sut.backup()
        
        originator.memento = TodoMemento(title: "B", task: "B task")
        sut.backup()
        
        // When
        sut.undo()
        
        // Then
        XCTAssertEqual(originator.restoreCallHistory.last?.title, "A")
        XCTAssertEqual(originator.restoreCallHistory.last?.task, "A task")
    }
    
    func testRedo_restoresNextStateAfterUndo() {
        // Given
        originator.memento = TodoMemento(title: "First", task: "1")
        sut.backup()
        
        originator.memento = TodoMemento(title: "Second", task: "2")
        sut.backup()
        
        sut.undo()
        
        // When
        sut.redo()
        
        // Then
        XCTAssertEqual(originator.restoreCallHistory.last?.title, "Second")
        XCTAssertEqual(originator.restoreCallHistory.last?.task, "2")
    }
    
    func testStatusPublisher_emitsCorrectValues() {
        // Given
        let expectation = XCTestExpectation()
        expectation.expectedFulfillmentCount = 5
        
        var statuses: [HistoryStatus] = []
        
        sut.status
            .sink { status in
                statuses.append(status)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        sut.backup()
        
        originator.memento = TodoMemento(title: "1", task: "Task")
        sut.backup()
        
        originator.memento = TodoMemento(title: "2", task: "Task")
        sut.backup()
        
        sut.undo()
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        
        XCTAssertEqual(statuses.count, 5)

        let statusAfterFirstBackup = statuses[1]
        let statusAfterSecondBackup = statuses[2]
        let statusAfterThirdBackup = statuses[3]
        let statusAfterUndo = statuses[4]
        
        XCTAssertFalse(statusAfterFirstBackup.isUndoAvailable)
        XCTAssertFalse(statusAfterFirstBackup.isRedoAvailable)
        
        XCTAssertTrue(statusAfterSecondBackup.isUndoAvailable)
        XCTAssertFalse(statusAfterSecondBackup.isRedoAvailable)
        
        XCTAssertTrue(statusAfterThirdBackup.isUndoAvailable)
        XCTAssertFalse(statusAfterThirdBackup.isRedoAvailable)
        
        XCTAssertTrue(statusAfterUndo.isUndoAvailable)
        XCTAssertTrue(statusAfterUndo.isRedoAvailable)
    }
}
