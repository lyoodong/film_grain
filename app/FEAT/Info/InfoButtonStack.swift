import SwiftUI

struct InfoButtonStack: View {
    @ObservedObject var infoVM: InfoViewModel
    
    var body: some View {
        VStack {
            InfoButton(type: .privacy) { }
            InfoButton(type: .terms) { }
            InfoButton(type: .review) { }
            InfoButton(type: .email) { }
        }
    }
}
