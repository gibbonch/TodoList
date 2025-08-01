import UIKit

struct ErrorModel {
    let message: String
}

extension UIViewController {
    
    func presentError(model: ErrorModel) {
        let errorView = UIView()
        errorView.backgroundColor = .redAsset
        errorView.layer.cornerRadius = 12
        errorView.clipsToBounds = true
        
        let label = UILabel()
        label.text = model.message
        label.textColor = .white
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        
        errorView.addSubview(label)
        errorView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(errorView)
        
        let bottomConstraint = errorView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 100)
        NSLayoutConstraint.activate([
            errorView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
            errorView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16),
            label.topAnchor.constraint(equalTo: errorView.topAnchor, constant: 12),
            label.bottomAnchor.constraint(equalTo: errorView.bottomAnchor, constant: -12),
            label.leadingAnchor.constraint(equalTo: errorView.leadingAnchor, constant: 12),
            label.trailingAnchor.constraint(equalTo: errorView.trailingAnchor, constant: -12),
            bottomConstraint
        ])
        
        self.view.layoutIfNeeded()
        
        bottomConstraint.constant = -40
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
        
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(dismissErrorView(_:)))
        swipe.direction = .down
        errorView.addGestureRecognizer(swipe)
        errorView.isUserInteractionEnabled = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.dismissErrorViewAnimated(errorView)
        }
    }
    
    @objc private func dismissErrorView(_ gesture: UISwipeGestureRecognizer) {
        if let view = gesture.view {
            dismissErrorViewAnimated(view)
        }
    }
    
    private func dismissErrorViewAnimated(_ view: UIView) {
        UIView.animate(withDuration: 0.3, animations: {
            view.alpha = 0
        }) { _ in
            view.removeFromSuperview()
        }
    }
}

