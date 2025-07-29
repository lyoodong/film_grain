import SwiftUI
import PhotosUI
import UniformTypeIdentifiers

extension PhotosPickerItem {
    func toImage() async -> UIImage? {
        do {
            if let data = try await loadTransferable(type: Data.self) {
                return UIImage(data: data)?.fixedOrientation()
            }
        } catch {
            print("❌ loadTransferable 실패:", error.localizedDescription)
        }
        
        return nil
    }
    
    // 지원하는 타입 중에서 가장 선호되는 타입 리턴
    // 가능하면 heic 리턴
    func loadPreferredType() -> UTType {
        let supported = self.supportedContentTypes
        return supported.contains(.heic) ? .heic : supported.first ?? .jpeg
    }
}
