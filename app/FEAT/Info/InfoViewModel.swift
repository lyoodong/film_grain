import SwiftUI

extension InfoViewModel: ViewModelType {
    struct State {
        var versionText: String = ""
    }
    
    enum Action {
        case onAppear
        case privacyButtonTapped
        case termsButtonTapped
    }
}

final class InfoViewModel: toVM<InfoViewModel> {
    override func reduce(state: inout State, action: Action) {
        switch action {
        case .onAppear:
            state.versionText = "Version " + AppInfo.appVersion
        
        case .privacyButtonTapped:
            openSafari(type: .privacy)
            
        case .termsButtonTapped:
            openSafari(type: .terms)
        }
    }
    
    private func openSafari(type: Url) {
        UIApplication.shared.open(type.value)
    }
}
