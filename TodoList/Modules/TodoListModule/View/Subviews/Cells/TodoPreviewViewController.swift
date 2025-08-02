import UIKit

final class TodoPreviewViewController: UIViewController {
    
    // MARK: - Private Properties
    
    private let todoView: TodoView = {
        let view = TodoView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let todo: TodoCellModel
    
    // MARK: - Lifecycle
    
    init(todo: TodoCellModel) {
        self.todo = todo
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPreview()
    }
    
    // MARK: - Private Methods
    
    private func setupPreview() {
        view.backgroundColor = .grayAsset
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        
        view.addSubview(todoView)
        
        NSLayoutConstraint.activate([
            todoView.topAnchor.constraint(equalTo: view.topAnchor, constant: 12),
            todoView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            todoView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            todoView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -12)
        ])
        
        todoView.configure(todo: todo)
    }
}
