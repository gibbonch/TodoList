import UIKit

final class ShimmerView: UIView {
    
    private(set) var isAnimating = false

    private let gradientColorOne = UIColor.grayAsset.cgColor
    private let gradientColorTwo = UIColor.grayAsset.lighter(by: 10).cgColor
    
    func startAnimating() {
        guard isAnimating == false else { return }
        
        let gradientLayer = addGradientLayer()
        let animation = addAnimation()
       
        gradientLayer.add(animation, forKey: animation.keyPath)
        isAnimating = true
    }
    
    func stopAnimating() {
        layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        isAnimating = false
    }
    
    private func addGradientLayer() -> CAGradientLayer {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.bounds
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 1.0)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
        gradientLayer.colors = [gradientColorOne, gradientColorTwo, gradientColorOne]
        gradientLayer.locations = [0.0, 0.5, 1.0]
        self.layer.addSublayer(gradientLayer)
        return gradientLayer
    }
    
    private func addAnimation() -> CABasicAnimation {
        let animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = [-1.0, -0.5, 0.0]
        animation.toValue = [1.0, 1.5, 2.0]
        animation.repeatCount = .infinity
        animation.duration = 0.9
        return animation
    }
}
