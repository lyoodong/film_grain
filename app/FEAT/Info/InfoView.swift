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
    }
    
    private func onAppear() {
        infoVM.send(.onAppear)
    }
}
