import SwiftUI
import PhotosUI

struct UploadPhotoPickerView: UIViewControllerRepresentable {
    var onPicked: (String?) -> Void

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
        Coordinator(onPicked: onPicked)
    }

    final class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let onPicked: (String?) -> Void

        init(onPicked: @escaping (String?) -> Void) {
            self.onPicked = onPicked
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            UIApplication.shared.rootViewController?.dismiss(animated: true) { [weak self] in
                guard let self else { return }
                if let id = results.first?.assetIdentifier {
                    onPicked(id)
                }
            }
        }
    }
}

