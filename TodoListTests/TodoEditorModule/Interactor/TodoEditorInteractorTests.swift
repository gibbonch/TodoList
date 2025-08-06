import XCTest
import Combine
@testable import Todo_List

final class TodoEditorInteractorTests: XCTestCase {
    
    private var sut: TodoEditorInteractor!
    private var repository: MockLocalTodoRepository!
    private var caretaker: MockCaretaker!
    private var builder: MockBuilder!
    private var output: MockTodoEditorOutput!
    
    private var cancellables: Set<AnyCancellable> = []
    
    override func setUp() {
        super.setUp()
        repository = MockLocalTodoRepository()
        caretaker = MockCaretaker()
        builder = MockBuilder()
        output = MockTodoEditorOutput()
        
        sut = TodoEditorInteractor(
            localRepository: repository,
            caretaker: caretaker,
            builder: builder
        )
        sut.output = output
    }
    
    override func tearDown() {
        sut = nil
        repository = nil
        caretaker = nil
        builder = nil
        output = nil
        cancellables = []
        super.tearDown()
    }
    
    func testUpdateTitle_callsBuilderAndBackups() {
        // When
        sut.updateTitle("New Title")
        
        // Then
        XCTAssertEqual(builder.title, "New Title")
        XCTAssertTrue(caretaker.backupCalled)
    }
    
    func testUpdateTask_callsBuilderAndBackups() {
        // When
        sut.updateTask("New Task")
        
        // Then
        XCTAssertEqual(builder.task, "New Task")
        XCTAssertTrue(caretaker.backupCalled)
    }
    
    func testSaveTask_callsUpdateIfExists() {
        // Given
        let todo = createTestTodo()
        builder.todoToBuild = todo
        repository.fetchTodoResult = .success(todo)
        
        // When
        sut.saveTask()
        
        // Then
        XCTAssertEqual(repository.fetchTodoCalledWith, todo.id)
        XCTAssertEqual(repository.updateTodoCalledWith, todo)
    }
    
    func testSaveTask_callsSaveIfNotExists() {
        // Given
        let todo = createTestTodo()
        builder.todoToBuild = todo
        repository.fetchTodoResult = .failure(NSError(domain: "", code: 0, userInfo: nil))
        
        // When
        sut.saveTask()
        
        // Then
        XCTAssertEqual(repository.saveTodoCalledWith, todo)
    }
    
    func testUndoLastChange_callsCaretakerAndOutput() {
        // Given
        builder.title = "Undo Title"
        builder.task = "Undo Task"
        
        // When
        sut.undoLastChange()
        
        // Then
        XCTAssertTrue(caretaker.undoCalled)
        XCTAssertEqual(output.receivedTitle, "Undo Title")
        XCTAssertEqual(output.receivedTask, "Undo Task")
    }
    
    func testRedoLastChange_callsCaretakerAndOutput() {
        // Given
        builder.title = "Redo Title"
        builder.task = "Redo Task"
        
        // When
        sut.redoLastChange()
        
        // Then
        XCTAssertTrue(caretaker.redoCalled)
        XCTAssertEqual(output.receivedTitle, "Redo Title")
        XCTAssertEqual(output.receivedTask, "Redo Task")
    }
    
    func testSubscribeOnHistoryStatus_callsOutputOnChange() {
        // Given
        let expected = HistoryStatus(isEmpty: false, isRedoAvailable: true, isUndoAvailable: true)
        let expectation = XCTestExpectation()
        
        output.receivedStatus = nil
        caretaker.emitStatus(expected)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(self.output.receivedStatus, expected)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Helpers
    
    private func createTestTodo() -> Todo {
        return Todo(
            id: UUID(),
            title: "Test Title",
            task: "Test Task",
            isCompleted: false,
            date: Date()
        )
    }
}

