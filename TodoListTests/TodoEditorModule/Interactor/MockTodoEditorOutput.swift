@testable import Todo_List

final class MockTodoEditorOutput: TodoEditorInteractorOutput {
    
    var receivedTitle: String?
    var receivedTask: String?
    var receivedStatus: HistoryStatus?
    
    func todoChanged(title: String, task: String) {
        receivedTitle = title
        receivedTask = task
    }
    
    func historyStatusChanged(_ status: HistoryStatus) {
        receivedStatus = status
    }
}
