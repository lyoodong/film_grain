import Foundation

extension InfoViewModel: ViewModelType {
    struct State {
        var versionText: String = ""
    }
    
    enum Action {
        case onAppear
    }
}

final class InfoViewModel: toVM<InfoViewModel> {
    override func reduce(state: inout State, action: Action) {
        switch action {
        case .onAppear:
            state.versionText = "Version " + AppInfo.appVersion
        }
    }
}
