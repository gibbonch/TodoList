import CoreData
import Combine

protocol LocalTodoRepositoryProtocol {
    var fetchedResults: AnyPublisher<[Todo], Never> { get }
    func fetchTodo(by id: UUID, completion: @escaping (Result<Todo, Error>) -> Void)
    func fetchAllTodos(completion: @escaping (Result<[Todo], Error>) -> Void)
    func fetchTodos(query: String)
    func saveTodo(_ todo: Todo, completion: ((Result<Void, Error>) -> Void)?)
    func saveTodos(_ todos: [Todo], completion: @escaping (Result<Void, Error>) -> Void)
    func deleteTodo(withId id: UUID, completion: ((Result<Void, Error>) -> Void)?)
    func toggleTodoCompletion(withId id: UUID, completion: @escaping (Result<Void, Error>) -> Void)
    func updateTodo(with updatedTodo: Todo, completion: ((Result<Void, Error>) -> Void)?)
}

final class LocalTodoRepository: NSObject, LocalTodoRepositoryProtocol {
    
    // MARK: - Internal Properties
    
    var fetchedResults: AnyPublisher<[Todo], Never> {
        fetchedResultsSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Private Properties
    
    private let contextProvider: ContextProvider
    private let fetchedResultsSubject = PassthroughSubject<[Todo], Never>()
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
    
    // MARK: - Internal Methods
    
    func fetchTodo(by id: UUID, completion: @escaping (Result<Todo, any Error>) -> Void) {
        contextProvider.performBackgroundTask { context in
            do {
                let request: NSFetchRequest<TodoEntity> = TodoEntity.fetchRequest()
                request.predicate = NSPredicate(format: "%K == %@",
                                                #keyPath(TodoEntity.uuid), id.uuidString)
                
                let todoEntity = try context.fetch(request).first
                
                guard let todo = todoEntity?.mapToDomain() else {
                    completion(.failure(TodoRepositoryError.todoNotFound))
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
                    completion?(.failure(TodoRepositoryError.todoNotFound))
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
                    completion(.failure(TodoRepositoryError.todoNotFound))
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
                    completion?(.failure(TodoRepositoryError.todoNotFound))
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
            updateFetchedResultsSubject()
        } catch {
            print("Failed to fetch todos: \(error)")
        }
    }
    
    private func updateFetchedResultsSubject() {
        guard let fetchedObjects = fetchedResultsController?.fetchedObjects else { return }
        let todos = fetchedObjects.map { $0.mapToDomain() }
        fetchedResultsSubject.send(todos)
    }
    
    @objc private func backgroundContextDidSave(_ notification: Notification) {
        guard let context = notification.object as? NSManagedObjectContext,
              context != contextProvider.viewContext else { return }
        
        // Merge изменения в view context на main queue
        DispatchQueue.main.async { [weak self] in
            self?.contextProvider.viewContext.mergeChanges(fromContextDidSave: notification)
        }
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension LocalTodoRepository: NSFetchedResultsControllerDelegate {
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        updateFetchedResultsSubject()
    }
}

enum TodoRepositoryError: Error, LocalizedError {
    case todoNotFound
}
