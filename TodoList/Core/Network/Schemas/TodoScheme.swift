import Foundation

struct TodoScheme: Decodable {
    let id: Int
    let todo: String
    let completed: Bool
}

extension TodoScheme {
    func mapToDomain() -> Todo {
        Todo(
            id: UUID(),
            title: "Задача #\(id)",
            task: todo,
            isCompleted: completed,
            date: Date()
        )
    }
}

struct TodosScheme: Decodable {
    let todos: [TodoScheme]
}
