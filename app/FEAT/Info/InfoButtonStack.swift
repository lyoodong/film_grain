import SwiftUI

struct InfoButtonStack: View {
    @ObservedObject var infoVM: InfoViewModel
    
    var body: some View {
        VStack {
            InfoButton(type: .privacy, action: privacyButtonAction)
            InfoButton(type: .terms) { }
            InfoButton(type: .review) { }
            InfoButton(type: .terms, action: termsButtonAction)
            InfoButton(type: .email) { }
        }
    }
    
    
    private func privacyButtonAction() {
        infoVM.send(.privacyButtonTapped)
    }
    
    private func termsButtonAction() {
        infoVM.send(.termsButtonTapped)
    }
}
