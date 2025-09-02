import SwiftUI
import Photos
import PhotosUI

extension UploadViewModel: ViewModelType {
    enum ActiveScreen: Equatable {
        case picker
        case edit
        case requestAuthorizationAlert
    }
    
    enum Loading: Equatable {
        case none
        case imageLoading
        case completeLoading
    }
    
    struct State {
        var activeScreen: ActiveScreen? = nil
        var loadingStatus: Loading = .none
        
        var originImage: UIImage?
    }
    
    enum Action {
        case uploadButtonTapped
        case onPicked(String)
        case dismiss
        
        case dataLoaded(Data)
        case imageLoaded(UIImage?)
        
        case showEdit
    }
}

final class UploadViewModel: toVM<UploadViewModel> {
    override func reduce(state: inout State, action: Action) {
        switch action {
        case .uploadButtonTapped:
            state.activeScreen = checkPHAuthorizationStatus()
            
        case .onPicked(let id):
            state.loadingStatus = .imageLoading
            fetchData(id)
            
        case .dataLoaded(let data):
            fetchImage(data)
            
        case .imageLoaded(let image):
            state.originImage = image
            state.loadingStatus = .completeLoading
            
        case .showEdit:
            state.loadingStatus = .none
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
    
    private func fetchData(_ id: String) {
        Task(priority: .userInitiated) {
            if let data = await loadData(id: id) {
                effect(.dataLoaded(data))
            }
        }
    }
    
    private func fetchImage(_ data: Data) {
        Task(priority: .userInitiated) {
            let image = data.downsampleToImage()
            try await Task.sleep(for: .seconds(0.8))
            effect(.imageLoaded(image))
        }
    }
}
