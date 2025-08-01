import UIKit

extension UIColor {
    
    func lighter(by percentage: CGFloat = 30.0) -> UIColor {
        return self.adjustBrightness(by: abs(percentage) )
    }
    
    private func adjustBrightness(by percentage: CGFloat = 30.0) -> UIColor {
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        
        guard self.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        else { return self }
        
        let newBrightness = min(brightness + percentage / 100, 1.0)
        return UIColor(hue: hue, saturation: saturation, brightness: newBrightness, alpha: alpha)
    }
}
