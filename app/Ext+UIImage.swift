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
    func encodedData(
        utType: UTType,
        from originalData: Data? = nil, 
        quality: CGFloat = 0.9
    ) -> Data? {
        
        guard let cg = self.cgImage else { return nil }
        
        var options: [CFString: Any] = [
            kCGImageDestinationLossyCompressionQuality: quality
        ]
        
        if
            let raw = originalData,
            let src = CGImageSourceCreateWithData(raw as CFData, nil),
            let meta = CGImageSourceCopyPropertiesAtIndex(src, 0, nil)
        {
            options[kCGImageDestinationMetadata] = meta
        }
        
        // (2) CGImageDestination 인코딩
        let data = NSMutableData()
        guard let dst = CGImageDestinationCreateWithData(
            data, utType.identifier as CFString, 1, nil) else { return nil }
        
        CGImageDestinationAddImage(dst, cg, options as CFDictionary)
        return CGImageDestinationFinalize(dst) ? data as Data : nil
    }
}


