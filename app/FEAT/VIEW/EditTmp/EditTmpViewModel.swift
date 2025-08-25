import SwiftUI
import Photos
import PhotosUI

extension EditTmpViewModel: ViewModelType {
    struct State {
        var selectedId: String
        var originData: Data = Data()
        var originImage: UIImage?
        var displayImage: UIImage?
        var isLoad = true
    }
    
    enum Action {
        case onAppear
        case dataFetched(Data)
        case imageFetched(UIImage?)
    }
}

final class EditTmpViewModel: toVM<EditTmpViewModel> {
    
    override func reduce(state: inout State, action: Action) {
        switch action {
        case .onAppear:
            let id = state.selectedId
            
            Task(priority: .userInitiated) {[weak self] in
                guard let self else { return }
                if let data = await loadData(id: id) {
                    effect(.dataFetched(data))
                }
            }
            
        case .dataFetched(let data):
            state.originData = data
            
            Task(priority: .userInitiated) { [weak self] in
                guard let self else { return }
                let image = downsample(data: data)
                effect(.imageFetched(image))
            }
            
        case .imageFetched(let image):
            state.isLoad = false
            state.originImage = image
            state.displayImage = image
        }
    }
    
    private func downsample(data: Data) -> UIImage? {
        let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        guard let imageSource = CGImageSourceCreateWithData(data as CFData, imageSourceOptions) else {
            return nil
        }
        
        let downsampleOptions = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: UIScreen.targetPixels
        ] as CFDictionary
        
        guard let downsampledImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampleOptions) else {
            return nil
        }
        
        return UIImage(cgImage: downsampledImage)
    }
    
    private func loadData(id: String) async -> Data? {
        let assets = PHAsset.fetchAssets(withLocalIdentifiers: [id], options: nil)
        guard let asset = assets.firstObject else { return nil }

        let options = PHImageRequestOptions()
        options.isSynchronous = false
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true

        return await withCheckedContinuation { continuation in
            PHImageManager.default().requestImageDataAndOrientation(for: asset, options: options) { data, uti, orientation, info in
                continuation.resume(returning: data)
            }
        }
    }
}
