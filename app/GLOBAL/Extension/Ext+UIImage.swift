import UIKit

extension UIImage {
    var aspectRatio: CGFloat {
        return self.size.width / self.size.height
    }
}

extension UIImage {
    func withoutAlpha() -> UIImage {
        let format = UIGraphicsImageRendererFormat.default()
        format.opaque = true
        format.scale = 1.0
        
        let renderer = UIGraphicsImageRenderer(size: self.size, format: format)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: self.size))
        }
    }
}

