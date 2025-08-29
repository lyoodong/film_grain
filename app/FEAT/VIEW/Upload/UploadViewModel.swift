import SwiftUI
import Photos
import PhotosUI

extension UploadViewModel: ViewModelType {
    enum ActiveScreen: Equatable {
        case picker
        case edit
        case requestAuthorizationAlert
    }
    
    struct State {
        var activeScreen: ActiveScreen? = nil
        var isLoading = false
        
        var originImage: UIImage?
        var displayImage: UIImage?
    }
    
    enum Action {
        case uploadButtonTapped
        case onPicked(String)
        case dismiss
        
        case dataLoaded(Data)
        case imageLoaded(UIImage?)
    }
}

final class UploadViewModel: toVM<UploadViewModel> {
    override func reduce(state: inout State, action: Action) {
        switch action {
        case .uploadButtonTapped:
            state.activeScreen = checkPHAuthorizationStatus()
            
        case .onPicked(let id):
            state.isLoading = true
            
            Task(priority: .userInitiated) {[weak self] in
                guard let self else { return }
                if let data = await loadData(id: id) {
                    effect(.dataLoaded(data))
                }
            }
            
        case .dataLoaded(let data):
            Task(priority: .userInitiated) { [weak self] in
                guard let self else { return }
                let image = downsample(data: data)
                try await Task.sleep(for: .seconds(2))
                effect(.imageLoaded(image))
            }
            
        case .imageLoaded(let image):
            state.isLoading = false
            state.originImage = image
            state.displayImage = image
            state.activeScreen = .edit
            
        case .dismiss:
            state.activeScreen = nil
        }
    }
}

//MARK: - Helpers
extension UploadViewModel {
    // 사진 권한 확인
    private func checkPHAuthorizationStatus() -> ActiveScreen {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        switch status {
        case .denied:
            return .requestAuthorizationAlert
        case .authorized, .limited:
            return .picker
        default:
            fatalError()
        }
    }
    
    //id를 통해 원본 Data 패치
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
    
    // 이미지 다운샘플링
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
}
