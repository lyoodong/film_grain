import SwiftUI

struct EditNavigation: View {
    let editVM: EditTmpViewModel
    @Environment(\.dismiss) var dismiss

    private let diameter: CGFloat = 40

    var body: some View {
        HStack(spacing: 12) {
            Button {
                dismiss()
            } label: {
                ZStack {
                    Circle().fill(.ultraThinMaterial)
                    Image(systemName: "xmark")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                }
                .frame(width: diameter, height: diameter)
            }
            .buttonStyle(.plain)
            
            Spacer()

            Button {
                editVM.send(.saveButtonTapped)
            } label: {
                ZStack {
                    Circle().fill(Color.mainRed)
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                }
                .frame(width: diameter, height: diameter)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
    }
}
