import SwiftUI
import PhotosUI
import UniformTypeIdentifiers

extension PhotosPickerItem {
    func toUIImage() async -> UIImage? {
        do {
            if let data = try await loadTransferable(type: Data.self) {
                return downsampleTo1024(data: data)?.fixedOrientation()
            }
        } catch {
            print("❌ loadTransferable 실패:", error.localizedDescription)
        }
        
        return nil
    }

    func downsampleTo1024(data: Data) -> UIImage? {
        guard let src = CGImageSourceCreateWithData(data as CFData, nil),
              let cg  = CGImageSourceCreateThumbnailAtIndex(src, 0, nil)
        else { return nil }

        let img = UIImage(cgImage: cg)
        return img.resized1024()
    }
}
