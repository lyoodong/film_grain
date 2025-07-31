import SwiftUI
import PhotosUI
import UniformTypeIdentifiers

extension PhotosPickerItem {
    func toUIImage() async -> UIImage? {
        do {
            if let data = try await loadTransferable(type: Data.self) {
                return UIImage(data: data)?.fixedOrientation().resized1024()
            }
        } catch {
            print("❌ loadTransferable 실패:", error.localizedDescription)
        }
        return nil
    }
}
