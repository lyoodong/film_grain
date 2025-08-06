import SwiftUI

extension UIScreen {
    static var maxScale: CGFloat {
        let size = UIScreen.main.bounds.size
        let scale = UIScreen.main.scale
        let max = max(size.height, size.width)
        
        return max * scale
    }
}

