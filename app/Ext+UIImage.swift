import SwiftUI
import ImageIO
import MobileCoreServices
import UniformTypeIdentifiers

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

extension UIImage {
    func encodedData(for utType: UTType, quality: CGFloat = 0.8) -> Data? {
        guard let cgImage = self.cgImage else { return nil }

        if utType == .png {
            return self.pngData()
        }

        let data = NSMutableData()
        guard let destination = CGImageDestinationCreateWithData(data, utType.identifier as CFString, 1, nil) else { return nil }

        let options = [kCGImageDestinationLossyCompressionQuality: quality] as CFDictionary
        CGImageDestinationAddImage(destination, cgImage, options)
        return CGImageDestinationFinalize(destination) ? data as Data : nil
    }
}


