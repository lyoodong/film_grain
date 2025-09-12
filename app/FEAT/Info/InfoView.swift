import SwiftUI

struct InfoView: View {
    
    var body: some View {
        VStack {
            InfoNavigation()
            InfoButtonStack()
            Spacer()
            InfoVersionText()
        }
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.mainBlack)
    }
}
