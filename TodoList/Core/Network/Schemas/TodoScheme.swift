import Foundation

/// Сетевая модель задачи.
struct TodoScheme: Decodable {
    
    /// Уникальный идентификатор задачи.
    let id: Int
    
    /// Описание задачи.
    let todo: String
    
    /// Статус выполнения.
    let completed: Bool
}

extension TodoScheme {
    
    /// Преобразует модель в доменную сущность Todo.
    ///
    /// Сетевая модель не полностью удовлетворяет требованиям приложения, поэтому часть данных генерируется случайным образом.
    /// - Returns: Доменная модель Todo с автоматически сгенерированными данными.
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
