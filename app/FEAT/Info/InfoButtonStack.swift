import SwiftUI

struct InfoButtonStack: View {
    @ObservedObject var infoVM: InfoViewModel
    
    var body: some View {
        VStack {
            InfoButton(type: .privacy, action: privacyButtonAction)
            InfoButton(type: .terms, action: termsButtonAction)
            InfoButton(type: .review, action: reviewButtonAction)
            InfoButton(type: .email) { }
        }
    }
    
    
    private func privacyButtonAction() {
        infoVM.send(.privacyButtonTapped)
    }
    
    private func termsButtonAction() {
        infoVM.send(.termsButtonTapped)
    }
    
    private func reviewButtonAction() {
        infoVM.send(.reviewButtonTapped)
    }
}
