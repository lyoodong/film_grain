import SwiftUI

extension CIColor {
    convenience init(_ color: Color) {
        let uiColor = UIColor(color)
        self.init(color: uiColor)
    }
}
