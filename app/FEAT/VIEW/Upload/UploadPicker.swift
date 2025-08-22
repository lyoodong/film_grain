import SwiftUI
import PhotosUI

struct UploadPhotoPickerView: UIViewControllerRepresentable {
    var onPicked: (String?) -> Void
    var onCancel: () -> Void

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration(photoLibrary: PHPhotoLibrary.shared())
        config.selectionLimit = 1
        config.filter = .any(of: [.images, .screenshots, .livePhotos])

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        picker.modalPresentationStyle = .fullScreen
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onPicked: onPicked, onCancel: onCancel)
    }

    final class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let onPicked: (String?) -> Void
        let onCancel: () -> Void

        init(onPicked: @escaping (String?) -> Void, onCancel: @escaping () -> Void) {
            self.onPicked = onPicked
            self.onCancel = onCancel
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            if let id = results.first?.assetIdentifier {
                onPicked(id)
            } else {
                onCancel()
            }
        }
    }
}

