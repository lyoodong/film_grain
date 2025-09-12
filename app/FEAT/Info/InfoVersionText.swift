import SwiftUI

struct InfoVersionText: View {
    var body: some View {
        HStack(alignment: .center) {
            Text("Version 1.0.0")
                .font(Poppin.regular.font(size: 12))
        }
        .padding(.bottom, 40)
    }
}
