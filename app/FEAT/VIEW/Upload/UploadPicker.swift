import UIKit
import Photos
import PhotosUI

final class UploadPhotoPicker: NSObject, PHPickerViewControllerDelegate {
    private var completion: ((String?) -> Void)?

    func present(completion: @escaping (String?) -> Void) {
        self.completion = completion

        var config = PHPickerConfiguration(photoLibrary: PHPhotoLibrary.shared())
        config.selectionLimit = 1
        config.filter = .any(of: [.images, .screenshots, .livePhotos])
        
        let picker = PHPickerViewController(configuration: config)
        picker.modalPresentationStyle = .fullScreen
        picker.delegate = self
        
        UIApplication.shared.rootViewController?.present(picker, animated: true)
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true) { [weak self] in
            guard let self else { return}
            
            guard let result = results.first,
                  let id = result.assetIdentifier else {
                completion?(nil)
                return
            }
            
            completion?(id)
        }
    }
}
