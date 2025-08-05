import Foundation
import CoreData

extension TodoEntity {
    
    /// Преобразует модель в доменную сущность Todo.
    func mapToDomain() -> Todo {
        Todo(
            id: uuid ?? UUID(),
            title: title ?? "",
            task: task ?? "",
            isCompleted: isCompleted,
            date: (date ?? Date()) as Date
        )
    }
}
