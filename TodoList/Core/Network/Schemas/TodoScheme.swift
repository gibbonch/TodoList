import Foundation

struct TodoScheme: Decodable {
    let id: Int
    let todo: String
    let completed: Bool
}

extension TodoScheme {
    
    func mapToDomain() -> Todo {
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: Date())
        
        let startOfYear = calendar.date(from: DateComponents(year: currentYear, month: 1, day: 1))!
        
        let today = Date()
        
        let randomTimeInterval = TimeInterval.random(
            in: startOfYear.timeIntervalSince1970...today.timeIntervalSince1970
        )
        let randomDate = Date(timeIntervalSince1970: randomTimeInterval)
        
        return Todo(
            id: UUID(),
            title: "Задача #\(self.id)",
            task: self.todo,
            isCompleted: self.completed,
            date: randomDate
        )
    }
}

struct TodosScheme: Decodable {
    let todos: [TodoScheme]
}
