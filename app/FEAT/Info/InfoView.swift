import SwiftUI

struct InfoView: View {
    @ObservedObject var infoVM: InfoViewModel
    
    var body: some View {
        VStack {
            InfoNavigation(infoVM: infoVM)
            InfoButtonStack(infoVM: infoVM)
            Spacer()
            InfoVersionText(infoVM: infoVM)
        }
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.mainBlack)
        .onAppear(perform: onAppear)
        .emailFullScreen(infoVM: infoVM)
    }
    
    private func onAppear() {
        infoVM.send(.onAppear)
    }
}

extension View {
    func emailFullScreen(infoVM: InfoViewModel) -> some View {
        modifier(EmailModifier(infoVM: infoVM))
    }
}

fileprivate struct EmailModifier: ViewModifier {
    @ObservedObject var infoVM: InfoViewModel
    
    func body(content: Content) -> some View {
        content.fullScreenCover(
            isPresented: Binding(
                get: { infoVM.activeScreen == .email },
                set: { if !$0 { infoVM.send(.dismiss)} }
            )
        ) {
            InfoEmailView(frame: infoVM.emailFrame)
        }
    }
}
