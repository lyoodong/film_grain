import SwiftUI
import Photos
import PhotosUI

extension UploadViewModel: ViewModelType {
    struct State {
        
    }
    
    enum Action {
        case photoSelected(PhotosPickerItem)
    }
}

final class UploadViewModel: toVM<UploadViewModel> {
    override func reduce(state: inout State, action: Action) {
        switch action {
        case .photoSelected(let item):
            print("photoSelected")
        }
    }
}
