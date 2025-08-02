import CoreData

protocol LocalTodoRepositoryProtocol {
    func fetchAllTodos(completion: @escaping (Result<[Todo], Error>) -> Void)
    func fetchTodos(query: String, completion: @escaping (Result<[Todo], Error>) -> Void)
    func saveTodo(_ todo: Todo, completion: @escaping (Result<Void, Error>) -> Void)
    func saveTodos(_ todos: [Todo], completion: @escaping (Result<Void, Error>) -> Void)
    func deleteTodo(withId id: UUID, completion: @escaping (Result<Void, Error>) -> Void)
    func toggleTodoCompletion(withId id: UUID, completion: @escaping (Result<Void, Error>) -> Void)
    func updateTodo(with updatedTodo: Todo, completion: @escaping (Result<Void, Error>) -> Void)
}

final class LocalTodoRepository: LocalTodoRepositoryProtocol {
    
    // MARK: - Private Properties
    
    private let contextProvider: ContextProvider
    
    // MARK: - Lifecycle
    
    init(contextProvider: ContextProvider = CoreDataStack.shared) {
        self.contextProvider = contextProvider
    }
    
    // MARK: - Internal Methods
    
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
    
    func fetchTodos(query: String, completion: @escaping (Result<[Todo], Error>) -> Void) {
        contextProvider.performBackgroundTask { context in
            do {
                let request: NSFetchRequest<TodoEntity> = TodoEntity.fetchRequest()
                
                if !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    let predicate = NSPredicate(format: "%K CONTAINS[cd] %@ OR %K CONTAINS[cd] %@",
                                                #keyPath(TodoEntity.title), query,
                                                #keyPath(TodoEntity.task), query)
                    request.predicate = predicate
                }
                
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
    
    func saveTodo(_ todo: Todo, completion: @escaping (Result<Void, Error>) -> Void) {
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
                
                completion(.success(()))
            } catch {
                completion(.failure(error))
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
    
    func deleteTodo(withId id: UUID, completion: @escaping (Result<Void, Error>) -> Void) {
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
                
                context.delete(todoEntity)
                try context.save()
                
                completion(.success(()))
            } catch {
                completion(.failure(error))
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
    
    func updateTodo(with updatedTodo: Todo, completion: @escaping (Result<Void, Error>) -> Void) {
        contextProvider.performBackgroundTask { context in
            do {
                let request: NSFetchRequest<TodoEntity> = TodoEntity.fetchRequest()
                request.predicate = NSPredicate(format: "%K == %@",
                                                #keyPath(TodoEntity.uuid), updatedTodo.id as CVarArg)
                
                let todoEntities = try context.fetch(request)
                
                guard let todoEntity = todoEntities.first else {
                    completion(.failure(TodoRepositoryError.todoNotFound))
                    return
                }
                
                todoEntity.title = updatedTodo.title
                todoEntity.task = updatedTodo.task
                todoEntity.isCompleted = updatedTodo.isCompleted
                todoEntity.date = updatedTodo.date
                
                try context.save()
                
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }
}

enum TodoRepositoryError: Error, LocalizedError {
    case todoNotFound
}
