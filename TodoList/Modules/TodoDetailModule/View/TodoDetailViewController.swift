import UIKit

final class TodoDetailViewController: UIViewController {
    
    // MARK: - Internal Properties
    
    
    // MARK: - Private Properties
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupNavigationBar()
        setupConstraints()
    }
    
    // MARK: - Private Methods
    
    private func setupView() {
        view.backgroundColor = .blackAsset
    }
    
    private func setupNavigationBar() {
        navigationController?.navigationBar.tintColor = .yellowAsset
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            
        ])
    }
}
