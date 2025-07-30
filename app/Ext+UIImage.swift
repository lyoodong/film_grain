import SwiftUI
import ImageIO
import MobileCoreServices
import UniformTypeIdentifiers

extension UIImage {
    func fixedOrientation() -> UIImage {
        guard imageOrientation != .up else { return self }
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(in: CGRect(origin: .zero, size: size))
        let out = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return out
    }
}

extension UIImage {
    func resized(to size: CGSize) -> UIImage {
        let fmt = UIGraphicsImageRendererFormat()
        fmt.scale = 1
        return UIGraphicsImageRenderer(size: size, format: fmt).image { _ in
            self.draw(in: CGRect(origin: .zero, size: size))
        }
    }
    
    func resized1024() -> UIImage {
        let width: CGFloat = 1024
        let ratio = width / size.width
        let height = floor(size.height * ratio)
        return resized(to: .init(width: width, height: height))
    }
}



