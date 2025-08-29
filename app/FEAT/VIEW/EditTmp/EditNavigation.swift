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
                        .font(.subheadline)
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
                    Circle().fill(.ultraThinMaterial)
                    Image(systemName: "square.and.arrow.up")
                        .font(.subheadline)
                        .foregroundColor(.white)
                }
                .frame(width: diameter, height: diameter)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
    }
}
