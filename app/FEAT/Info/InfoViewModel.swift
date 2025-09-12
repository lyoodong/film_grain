import SwiftUI
import StoreKit

extension InfoViewModel: ViewModelType {
    enum ActiveScreen {
        case none
        case email
    }
    
    struct State {
        var versionText: String = ""
        var activeScreen: ActiveScreen = .none
        var emailFrame = AppInfo.emailFrame
    }
    
    enum Action {
        case onAppear
        case dismiss
        case privacyButtonTapped
        case termsButtonTapped
        case reviewButtonTapped
        case emailButtonTapped
    }
}

final class InfoViewModel: toVM<InfoViewModel> {
    override func reduce(state: inout State, action: Action) {
        switch action {
        case .onAppear:
            state.versionText = AppInfo.appVersionText
            
        case .dismiss:
            state.activeScreen = .none
            
        case .privacyButtonTapped:
            openSafari(type: .privacy)
            
        case .termsButtonTapped:
            openSafari(type: .terms)
            
        case .reviewButtonTapped:
            requestReview()
            
        case .emailButtonTapped:
            state.activeScreen = .email
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
