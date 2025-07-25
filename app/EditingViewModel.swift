import SwiftUI

extension EditingViewModel: ViewModelType {
    struct State {
        var displayedImage: UIImage?
    }

    enum Action {
        case photoSelected(UIImage)
    }
}

final class EditingViewModel: toVM<EditingViewModel> {
    override func reduce(state: inout State, action: Action) {
        switch action {
            
        case .photoSelected(let photo):
            state.displayedImage = photo
        }
    }
}
