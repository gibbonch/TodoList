import Foundation
import CoreData

/// Протокол для работы с Core Data.
///
/// Предоставляет доступ к основному контексту и метод для фоновых операций.
protocol ContextProvider {
    
    /// Контекст главного потока для работы с UI.
    var viewContext: NSManagedObjectContext { get }
    
    /// Выполняет задачу в фоновом контексте.
    /// - Parameter block: Замыкание с фоновым контекстом.
    func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Void)
}


final class CoreDataStack: ContextProvider {
    
    // MARK: - Singleton
    
    static let shared = CoreDataStack()
    
    private init() { }
    
    // MARK: - Internal Properties
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TodoListDataModel")
        
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        
        return container
    }()
    
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    // MARK: - Internal Methods
    
    func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Void) {
        persistentContainer.performBackgroundTask(block)
    }
}
