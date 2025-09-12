import SwiftUI
import StoreKit

extension InfoViewModel: ViewModelType {
    struct State {
        var versionText: String = ""
    }
    
    enum Action {
        case onAppear
        case privacyButtonTapped
        case termsButtonTapped
        case reviewButtonTapped
    }
}

final class InfoViewModel: toVM<InfoViewModel> {
    override func reduce(state: inout State, action: Action) {
        switch action {
        case .onAppear:
            state.versionText = AppInfo.appVersionText
        
        case .privacyButtonTapped:
            openSafari(type: .privacy)
            
        case .termsButtonTapped:
            openSafari(type: .terms)
            
        case .reviewButtonTapped:
            requestReview()
        }
    }
    
    private func openSafari(type: Url) {
        UIApplication.shared.open(type.value)
    }
    
    private func requestReview() {
        let scene = UIApplication.shared.connectedScenes.first as! UIWindowScene
        Task { await AppStore.requestReview(in: scene) }
    }
}
