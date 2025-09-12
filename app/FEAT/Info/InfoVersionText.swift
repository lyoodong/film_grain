import SwiftUI

struct InfoVersionText: View {
    @ObservedObject var infoVM: InfoViewModel
    
    var body: some View {
        HStack(alignment: .center) {
            Text(infoVM.versionText)
                .font(Poppin.regular.font(size: 12))
        }
        .padding(.bottom, 40)
    }
}
