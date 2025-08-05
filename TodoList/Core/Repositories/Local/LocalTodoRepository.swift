import CoreData
import Combine

final class LocalTodoRepository: NSObject {
    
    // MARK: - Internal Properties
    
    var fetchedResults: AnyPublisher<[Todo], Never> {
        _fetchedResults.eraseToAnyPublisher()
    }
    
    // MARK: - Private Properties
    
    private let contextProvider: ContextProvider
    private let _fetchedResults = PassthroughSubject<[Todo], Never>()
    private var fetchedResultsController: NSFetchedResultsController<TodoEntity>?
    
    // MARK: - Lifecycle
    
    init(contextProvider: ContextProvider = CoreDataStack.shared) {
        self.contextProvider = contextProvider
        super.init()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(backgroundContextDidSave(_:)),
            name: .NSManagedObjectContextDidSave,
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Private Methods
    
    private func setupFetchedResultsController(with query: String? = nil) {
        let context = contextProvider.viewContext
        
        let request: NSFetchRequest<TodoEntity> = TodoEntity.fetchRequest()
        if let query, !query.isEmpty {
            let predicate = NSPredicate(format: "%K CONTAINS[cd] %@ OR %K CONTAINS[cd] %@",
                                        #keyPath(TodoEntity.title), query,
                                        #keyPath(TodoEntity.task), query)
            request.predicate = predicate
        }
        let sortDescriptor = NSSortDescriptor(key: #keyPath(TodoEntity.date), ascending: false)
        request.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        fetchedResultsController?.delegate = self
        
        do {
            try fetchedResultsController?.performFetch()
            updateFetchedResults()
        } catch {
            print("Failed to fetch todos: \(error)")
        }
    }
    
    private func updateFetchedResults() {
        guard let fetchedObjects = fetchedResultsController?.fetchedObjects else { return }
        let todos = fetchedObjects.map { $0.mapToDomain() }
        _fetchedResults.send(todos)
    }
    
    @objc private func backgroundContextDidSave(_ notification: Notification) {
        guard let context = notification.object as? NSManagedObjectContext,
              context != contextProvider.viewContext else { return }
        
        contextProvider.viewContext.mergeChanges(fromContextDidSave: notification)
    }
}

// MARK: - LocalTodoRepositoryProtocol

extension LocalTodoRepository: LocalTodoRepositoryProtocol {
    
    func fetchTodo(by id: UUID, completion: @escaping (Result<Todo, any Error>) -> Void) {
        contextProvider.performBackgroundTask { context in
            do {
                let request: NSFetchRequest<TodoEntity> = TodoEntity.fetchRequest()
                request.predicate = NSPredicate(format: "%K == %@",
                                                #keyPath(TodoEntity.uuid), id.uuidString)
                
                let todoEntity = try context.fetch(request).first
                
                guard let todo = todoEntity?.mapToDomain() else {
                    completion(.failure(LocalTodoRepositoryError.todoNotFound))
                    return
                }
                
                completion(.success(todo))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    func fetchAllTodos(completion: @escaping (Result<[Todo], Error>) -> Void) {
        contextProvider.performBackgroundTask { context in
            do {
                let request: NSFetchRequest<TodoEntity> = TodoEntity.fetchRequest()
                let sortDescriptor = NSSortDescriptor(key: #keyPath(TodoEntity.date), ascending: false)
                request.sortDescriptors = [sortDescriptor]
                
                let todoEntities = try context.fetch(request)
                let todos = todoEntities.map { $0.mapToDomain() }
                
                completion(.success(todos))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    func fetchTodos(query: String) {
        setupFetchedResultsController(with: query)
    }
    
    func saveTodo(_ todo: Todo, completion: ((Result<Void, Error>) -> Void)?) {
        contextProvider.performBackgroundTask { context in
            do {
                let request: NSFetchRequest<TodoEntity> = TodoEntity.fetchRequest()
                request.predicate = NSPredicate(format: "%K == %@",
                                                #keyPath(TodoEntity.uuid), todo.id as CVarArg)
                
                let existingEntities = try context.fetch(request)
                
                let todoEntity: TodoEntity
                if let existingEntity = existingEntities.first {
                    todoEntity = existingEntity
                } else {
                    todoEntity = TodoEntity(context: context)
                }
                
                todoEntity.uuid = todo.id
                todoEntity.title = todo.title
                todoEntity.task = todo.task
                todoEntity.isCompleted = todo.isCompleted
                todoEntity.date = todo.date
                
                try context.save()
                
                completion?(.success(()))
            } catch {
                completion?(.failure(error))
            }
        }
    }
    
    func saveTodos(_ todos: [Todo], completion: @escaping (Result<Void, Error>) -> Void) {
        guard !todos.isEmpty else {
            completion(.success(()))
            return
        }
        
        contextProvider.performBackgroundTask { context in
            do {
                let todoIds = todos.map { $0.id }
                let request: NSFetchRequest<TodoEntity> = TodoEntity.fetchRequest()
                request.predicate = NSPredicate(format: "%K IN %@",
                                                #keyPath(TodoEntity.uuid), todoIds)
                
                let existingEntities = try context.fetch(request)
                
                var existingEntitiesMap: [UUID: TodoEntity] = [:]
                for entity in existingEntities {
                    if let uuid = entity.uuid {
                        existingEntitiesMap[uuid] = entity
                    }
                }
                
                for todo in todos {
                    let todoEntity: TodoEntity
                    
                    if let existingEntity = existingEntitiesMap[todo.id] {
                        todoEntity = existingEntity
                    } else {
                        todoEntity = TodoEntity(context: context)
                    }
                    
                    todoEntity.uuid = todo.id
                    todoEntity.title = todo.title
                    todoEntity.task = todo.task
                    todoEntity.isCompleted = todo.isCompleted
                    todoEntity.date = todo.date
                }
                
                try context.save()
                
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    func deleteTodo(withId id: UUID, completion: ((Result<Void, Error>) -> Void)?) {
        contextProvider.performBackgroundTask { context in
            do {
                let request: NSFetchRequest<TodoEntity> = TodoEntity.fetchRequest()
                request.predicate = NSPredicate(format: "%K == %@",
                                                #keyPath(TodoEntity.uuid), id as CVarArg)
                
                let todoEntities = try context.fetch(request)
                
                guard let todoEntity = todoEntities.first else {
                    completion?(.failure(LocalTodoRepositoryError.todoNotFound))
                    return
                }
                
                context.delete(todoEntity)
                try context.save()
                
                completion?(.success(()))
            } catch {
                completion?(.failure(error))
            }
        }
    }
    
    func toggleTodoCompletion(withId id: UUID, completion: @escaping (Result<Void, Error>) -> Void) {
        contextProvider.performBackgroundTask { context in
            do {
                let request: NSFetchRequest<TodoEntity> = TodoEntity.fetchRequest()
                request.predicate = NSPredicate(format: "%K == %@",
                                                #keyPath(TodoEntity.uuid), id as CVarArg)
                
                let todoEntities = try context.fetch(request)
                
                guard let todoEntity = todoEntities.first else {
                    completion(.failure(LocalTodoRepositoryError.todoNotFound))
                    return
                }
                
                todoEntity.isCompleted.toggle()
                try context.save()
                
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    func updateTodo(with updatedTodo: Todo, completion: ((Result<Void, Error>) -> Void)?) {
        contextProvider.performBackgroundTask { context in
            do {
                let request: NSFetchRequest<TodoEntity> = TodoEntity.fetchRequest()
                request.predicate = NSPredicate(format: "%K == %@",
                                                #keyPath(TodoEntity.uuid), updatedTodo.id as CVarArg)
                
                let todoEntities = try context.fetch(request)
                
                guard let todoEntity = todoEntities.first else {
                    completion?(.failure(LocalTodoRepositoryError.todoNotFound))
                    return
                }
                
                todoEntity.title = updatedTodo.title
                todoEntity.task = updatedTodo.task
                todoEntity.isCompleted = updatedTodo.isCompleted
                todoEntity.date = updatedTodo.date
                
                try context.save()
                
                completion?(.success(()))
            } catch {
                completion?(.failure(error))
            }
        }
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension LocalTodoRepository: NSFetchedResultsControllerDelegate {
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        updateFetchedResults()
    }
}
