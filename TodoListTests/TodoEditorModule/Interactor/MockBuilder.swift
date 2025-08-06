@testable import Todo_List

final class MockBuilder: TodoBuilderProtocol {
    
    var title: String = ""
    var task: String = ""
    var todoToBuild: Todo?
    
    func build() -> Todo? {
        return todoToBuild
    }
}
