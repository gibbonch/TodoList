import XCTest
import Combine
@testable import Todo_List

final class TodoListInteractorTests: XCTestCase {
    
    // MARK: - Private Properties
    
    private var sut: TodoListInteractor!
    private var remote: MockRemoteTodoRepository!
    private var local: TodoListMockLocalTodoRepository!
    private var output: MockTodoListInteractorOutput!
    private var defaults: UserDefaults!
    private var suiteName: String!
    
    private var cancellables: Set<AnyCancellable> = []
    
    // MARK: - Lifecycle
    
    override func setUp() {
        super.setUp()
        
        suiteName = "TodoListInteractorTests.UserDefaults"
        UserDefaults().removePersistentDomain(forName: suiteName)
        defaults = UserDefaults(suiteName: suiteName)
        
        remote = MockRemoteTodoRepository()
        local = TodoListMockLocalTodoRepository()
        output = MockTodoListInteractorOutput()
        
        sut = TodoListInteractor(
            remoteRepository: remote,
            localRepository: local,
            defaults: defaults
        )
        sut.output = output
    }
    
    override func tearDown() {
        if let suiteName = suiteName {
            UserDefaults().removePersistentDomain(forName: suiteName)
        }
        sut = nil
        remote = nil
        local = nil
        output = nil
        defaults = nil
        suiteName = nil
        
        super.tearDown()
    }
    
    // MARK: - Tests
    
    func testFetchTodos_readsFromLocalWhenSkipLoading() {
        // Given
        defaults.set(true, forKey: "initialized")
        
        // When
        sut.fetchTodos(skipLoading: true)
        
        // Then
        XCTAssertEqual(local.fetchTodosCalledWith, "")
        XCTAssertFalse(remote.fetchTodosCalled)
    }
    
    func testFetchTodos_savesToLocalAndFetches() {
        // Given
        let todo = createTestTodo()
        remote.todosToReturn = [todo]
        
        // When
        sut.fetchTodos(skipLoading: false)
        
        // Then
        XCTAssertTrue(remote.fetchTodosCalled)
        XCTAssertEqual(local.savedTodos, [todo])
        XCTAssertTrue(defaults.bool(forKey: "initialized"))
    }
    
    func testFetchTodos_callsHandleFailureWhenFetchingFailed() {
        // Given
        remote.errorToReturn = TodoListInteractorMockError.saveFailed
        
        // When
        sut.fetchTodos(skipLoading: false)
        
        // Then
        XCTAssertEqual(output.receivedErrors, [.initialLoadingFailure])
    }
    
    func testFetchTodos_callsHandleFailureWhenSavingFailed() {
        // Given
        remote.todosToReturn = [createTestTodo()]
        local.saveTodosShouldFail = true
        
        // When
        sut.fetchTodos(skipLoading: false)
        
        // Then
        XCTAssertEqual(output.receivedErrors, [.initialLoadingFailure])
    }
    
    func testFetchTodosByQuery_callsLocalRepositoryWithQuery() {
        // When
        sut.fetchTodos(by: "search text")
        
        // Then
        XCTAssertEqual(local.fetchTodosCalledWith, "search text")
    }
    
    func testDeleteTodo_callsLocalDelete() {
        // Given
        let id = UUID()
        
        // When
        sut.deleteTodo(with: id)
        
        // Then
        XCTAssertEqual(local.deletedTodoId, id)
    }
    
    func testToggleCompletion_callsLocalRepository() {
        // Given
        let id = UUID()
        
        // When
        sut.toggleCompletionOnTodo(with: id)
        
        // Then
        XCTAssertEqual(local.toggleCompletionCalledWith, id)
    }
    
    func testToggleCompletion_callsHandleFailure() {
        // Given
        local.toggleShouldFail = true
        let id = UUID()
        
        // When
        sut.toggleCompletionOnTodo(with: id)
        
        // Then
        XCTAssertEqual(output.receivedErrors, [.editingFailure])
    }
    
    func testLocalRepositoryEmits_updateTodosIsCalled() {
        // Given
        let todo = createTestTodo()
        
        let expectation = XCTestExpectation()
        output.didUpdate = {
            expectation.fulfill()
        }
        
        // When
        local.fetchedResultsSubject.send([todo])
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(output.updatedTodos.first, [todo])
    }
    
    // MARK: - Private Methods
    
    private func createTestTodo() -> Todo {
        Todo(
            id: UUID(),
            title: "Test",
            task: "Task",
            isCompleted: false,
            date: Date()
        )
    }
}
