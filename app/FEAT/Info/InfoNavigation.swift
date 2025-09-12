import SwiftUI

struct InfoNavigation: View {
    @ObservedObject var infoVM: InfoViewModel
    @Environment(\.dismiss) var dismiss
    
    private let font = Poppin.semiBold.font(size: 20)
    private let diameter: CGFloat = 40
    
    var body: some View {
        HStack {
            Spacer()
            Button(action: dismissButtonTapped, label: dismissButtonLabel)
        }
    }
    
    private func dismissButtonTapped() -> Void {
        dismiss()
    }
    
    private func dismissButtonLabel() -> some View {
        return Image(systemName: "xmark")
            .font(font)
            .foregroundColor(.white)
            .frame(width: diameter, height: diameter)
    }
}
