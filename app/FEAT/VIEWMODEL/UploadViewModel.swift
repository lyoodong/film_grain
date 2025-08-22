import SwiftUI
import Photos
import PhotosUI

extension UploadViewModel: ViewModelType {
    enum ActiveScreen: Equatable {
        case none
        case picker
        case requestAuthorizationAlert
    }
    
    struct State {
        var activeScreen:ActiveScreen = .none
        var selectedId: String?
    }
    
    enum Action {
        case photoAuthChecked(PHAuthorizationStatus)
        case uploadButtonTapped
        case dismissPicker
    }
}

final class UploadViewModel: toVM<UploadViewModel> {
    
    override func reduce(state: inout State, action: Action) {
        switch action {
        case .photoAuthChecked(let status):
            let isAuthorized = status == .authorized || status == .limited
            state.activeScreen = isAuthorized ? .picker : .requestAuthorizationAlert
            
        case .uploadButtonTapped:
            checkPHAuthorizationStatus { [weak self] status in
                guard let self else { return }
                self.effect(.photoAuthChecked(status))
            }
            
        case .dismissPicker:
            state.activeScreen = .none
        }
    }
}

extension UploadViewModel {
    private func checkPHAuthorizationStatus(completion: @escaping (PHAuthorizationStatus) -> Void) {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        
        switch status {
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
                completion(status)
            }
            
        case .restricted, .denied, .authorized, .limited:
            completion(status)
            
        @unknown default:
            completion(status)
        }
    }
}
