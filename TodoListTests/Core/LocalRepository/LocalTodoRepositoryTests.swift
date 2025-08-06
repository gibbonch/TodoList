import CoreData
import Combine
import XCTest
@testable import Todo_List

final class LocalTodoRepositoryTests: XCTestCase {
    
    // MARK: - Private Properties
    
    private var sut: LocalTodoRepository!
    private var contextProvider: ContextProvider!
    private var cancellables: Set<AnyCancellable>!
    
    // MARK: - Lifecycle
    
    override func setUp() {
        super.setUp()
        contextProvider = MockContextProvider()
        sut = LocalTodoRepository(contextProvider: contextProvider)
        cancellables = Set<AnyCancellable>()
    }
    
    override func tearDown() {
        cancellables = nil
        sut = nil
        contextProvider = nil
        super.tearDown()
    }
    
    // MARK: - Tests
    
    func testSaveTodo_resultsWithSuccess() {
        // Given
        let todo = createTestTodo()
        let expectation = XCTestExpectation()
        
        // When
        sut.saveTodo(todo) { result in
            // Then
            switch result {
            case .success:
                expectation.fulfill()
            case .failure:
                XCTFail()
            }
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testSaveTodo_updatesExistingTodo() {
        // Given
        let todo = createTestTodo()
        let expectation1 = XCTestExpectation()
        let expectation2 = XCTestExpectation()
        
        // When
        sut.saveTodo(todo) { result in
            XCTAssertTrue(result.isSuccess)
            expectation1.fulfill()
        }
        
        wait(for: [expectation1], timeout: 1.0)
        
        let updatedTodo = Todo(
            id: todo.id,
            title: "Updated Title",
            task: "Updated Task",
            isCompleted: true,
            date: Date()
        )
        
        sut.saveTodo(updatedTodo) { result in
            XCTAssertTrue(result.isSuccess)
            expectation2.fulfill()
        }
        
        wait(for: [expectation2], timeout: 1.0)
        
        // Then
        let expectation3 = XCTestExpectation()
        sut.fetchTodo(by: todo.id) { result in
            switch result {
            case .success(let fetchedTodo):
                XCTAssertEqual(fetchedTodo.title, "Updated Title")
                XCTAssertEqual(fetchedTodo.task, "Updated Task")
                XCTAssertTrue(fetchedTodo.isCompleted)
                expectation3.fulfill()
            case .failure:
                XCTFail()
            }
        }
        
        wait(for: [expectation3], timeout: 1.0)
    }
    
    func testSaveTodos_resultsWithSuccess() {
        // Given
        let todos = [
            createTestTodo(title: "Todo 1"),
            createTestTodo(title: "Todo 2"),
            createTestTodo(title: "Todo 3")
        ]
        let expectation = XCTestExpectation()
        
        // When
        sut.saveTodos(todos) { result in
            // Then
            XCTAssertTrue(result.isSuccess)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
        
        let fetchExpectation = XCTestExpectation()
        sut.fetchAllTodos { result in
            switch result {
            case .success(let fetchedTodos):
                XCTAssertEqual(fetchedTodos.count, 3)
                fetchExpectation.fulfill()
            case .failure:
                XCTFail()
            }
        }
        
        wait(for: [fetchExpectation], timeout: 1.0)
    }
    
    func testFetchTodo_returnsExistingTodo() {
        // Given
        let todo = createTestTodo()
        let saveExpectation = XCTestExpectation()
        let fetchExpectation = XCTestExpectation()
        
        // When
        sut.saveTodo(todo) { result in
            XCTAssertTrue(result.isSuccess)
            saveExpectation.fulfill()
        }
        
        wait(for: [saveExpectation], timeout: 1.0)
        
        sut.fetchTodo(by: todo.id) { result in
            // Then
            switch result {
            case .success(let fetchedTodo):
                XCTAssertEqual(fetchedTodo.id, todo.id)
                XCTAssertEqual(fetchedTodo.title, todo.title)
                XCTAssertEqual(fetchedTodo.task, todo.task)
                XCTAssertEqual(fetchedTodo.isCompleted, todo.isCompleted)
                fetchExpectation.fulfill()
            case .failure:
                XCTFail()
            }
        }
        
        wait(for: [fetchExpectation], timeout: 1.0)
    }
    
    func testFetchTodo_returnsFailureForNonExistingTodo() {
        // Given
        let nonExistingId = UUID()
        let expectation = XCTestExpectation()
        
        // When
        sut.fetchTodo(by: nonExistingId) { result in
            // Then
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                XCTAssertTrue(error is LocalTodoRepositoryError)
                if let repositoryError = error as? LocalTodoRepositoryError {
                    XCTAssertEqual(repositoryError, .todoNotFound)
                }
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testFetchAllTodos_returnsExistingTodos() {
        // Given
        let todos = [
            createTestTodo(title: "Todo 1"),
            createTestTodo(title: "Todo 2")
        ]
        let saveExpectation = XCTestExpectation()
        let fetchExpectation = XCTestExpectation()
        
        // When
        sut.saveTodos(todos) { result in
            XCTAssertTrue(result.isSuccess)
            saveExpectation.fulfill()
        }
        
        wait(for: [saveExpectation], timeout: 1.0)
        
        sut.fetchAllTodos { result in
            // Then
            switch result {
            case .success(let fetchedTodos):
                XCTAssertEqual(fetchedTodos.count, 2)
                XCTAssertTrue(fetchedTodos[0].date >= fetchedTodos[1].date)
                fetchExpectation.fulfill()
            case .failure:
                XCTFail()
            }
        }
        
        wait(for: [fetchExpectation], timeout: 1.0)
    }
    
    func testFetchAllTodos_returnsEmptyArrayWhenNoExistingTodos() {
        // Given
        let expectation = XCTestExpectation()
        
        // When
        sut.fetchAllTodos { result in
            // Then
            switch result {
            case .success(let todos):
                XCTAssertTrue(todos.isEmpty)
                expectation.fulfill()
            case .failure:
                XCTFail()
            }
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testDeleteTodo_deletesExistingTodo() {
        // Given
        let todo = createTestTodo()
        let saveExpectation = XCTestExpectation()
        let deleteExpectation = XCTestExpectation()
        
        // When
        sut.saveTodo(todo) { result in
            XCTAssertTrue(result.isSuccess)
            saveExpectation.fulfill()
        }
        
        wait(for: [saveExpectation], timeout: 1.0)
        
        sut.deleteTodo(withId: todo.id) { result in
            // Then
            XCTAssertTrue(result.isSuccess)
            deleteExpectation.fulfill()
        }
        
        wait(for: [deleteExpectation], timeout: 1.0)
        
        let fetchExpectation = XCTestExpectation()
        sut.fetchTodo(by: todo.id) { result in
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                XCTAssertTrue(error is LocalTodoRepositoryError)
                fetchExpectation.fulfill()
            }
        }
        
        wait(for: [fetchExpectation], timeout: 1.0)
    }
    
    func testDeleteTodo_returnsFailureForNonExistingTodo() {
        // Given
        let nonExistingId = UUID()
        let expectation = XCTestExpectation()
        
        // When
        sut.deleteTodo(withId: nonExistingId) { result in
            // Then
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                XCTAssertTrue(error is LocalTodoRepositoryError)
                if let repositoryError = error as? LocalTodoRepositoryError {
                    XCTAssertEqual(repositoryError, .todoNotFound)
                }
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testToggleTodoCompletion_togglesExistingTodo() {
        // Given
        let todo = createTestTodo(isCompleted: false)
        let saveExpectation = XCTestExpectation()
        let toggleExpectation = XCTestExpectation()
        
        // When
        sut.saveTodo(todo) { result in
            XCTAssertTrue(result.isSuccess)
            saveExpectation.fulfill()
        }
        
        wait(for: [saveExpectation], timeout: 1.0)
        
        sut.toggleTodoCompletion(withId: todo.id) { result in
            // Then
            XCTAssertTrue(result.isSuccess)
            toggleExpectation.fulfill()
        }
        
        wait(for: [toggleExpectation], timeout: 1.0)
        
        let fetchExpectation = XCTestExpectation()
        sut.fetchTodo(by: todo.id) { result in
            switch result {
            case .success(let fetchedTodo):
                XCTAssertTrue(fetchedTodo.isCompleted)
                fetchExpectation.fulfill()
            case .failure:
                XCTFail()
            }
        }
        
        wait(for: [fetchExpectation], timeout: 1.0)
    }
    
    func testToggleTodoCompletion_returnsFailureForNonExistingTodo() {
        // Given
        let nonExistingId = UUID()
        let expectation = XCTestExpectation()
        
        // When
        sut.toggleTodoCompletion(withId: nonExistingId) { result in
            // Then
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                XCTAssertTrue(error is LocalTodoRepositoryError)
                if let repositoryError = error as? LocalTodoRepositoryError {
                    XCTAssertEqual(repositoryError, .todoNotFound)
                }
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Private Methods
    
    private func createTestTodo(
        id: UUID = UUID(),
        title: String = "Test Todo",
        task: String = "Test task description",
        isCompleted: Bool = false,
        date: Date = Date()
    ) -> Todo {
        Todo(
            id: id,
            title: title,
            task: task,
            isCompleted: isCompleted,
            date: date
        )
    }
}

// MARK: - Result Extension for Testing

fileprivate extension Result {
    
    var isSuccess: Bool {
        switch self {
        case .success:
            return true
        case .failure:
            return false
        }
    }
    
    var isFailure: Bool {
        return !isSuccess
    }
}
