import Foundation
import CoreData

extension TodoEntity {
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
