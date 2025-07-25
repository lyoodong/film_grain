import UIKit

extension UIImage {
    /// Returns an image with orientation normalized to `.up`
    func fixedOrientation() -> UIImage {
        guard imageOrientation != .up else { return self }
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(in: CGRect(origin: .zero, size: size))
        let out = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return out
    }
}
