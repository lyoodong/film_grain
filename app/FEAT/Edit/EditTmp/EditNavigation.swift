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
                    Circle().fill(Color.mainGray)
                    
                    Image(systemName: "xmark")
                        .font(Poppin.medium.font(size: 16))
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
                    Capsule()
                        .fill(Color.mainGray)
                    
                    Image(systemName: "square.and.arrow.up")
                        .font(Poppin.medium.font(size: 16))
                        .foregroundColor(.white)
                }
                .frame(width: diameter, height: diameter)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
    }
}
