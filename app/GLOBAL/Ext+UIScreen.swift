import SwiftUI

extension UIScreen {
    static var targetPixels: CGFloat {
        UIScreen.main.bounds.width * UIScreen.main.scale
    }
}

