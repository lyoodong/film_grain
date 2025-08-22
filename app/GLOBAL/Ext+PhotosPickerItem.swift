import SwiftUI
import PhotosUI
import UniformTypeIdentifiers

extension PhotosPickerItem {
    func toUIImage() async -> UIImage? {
        do {
            if let data = try await loadTransferable(type: Data.self) {
                return UIImage(data: data)?.fixedOrientation()
            }
        } catch {
            print("❌ loadTransferable 실패:", error.localizedDescription)
        }
        return nil
    }
    
    func toData() async -> Data? {
        do {
            if let data = try await loadTransferable(type: Data.self) {
                return data
            }
        } catch {
            print("❌ loadTransferable data 실패:", error.localizedDescription)
        }
        
        return nil
    }
}
