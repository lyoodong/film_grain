import SwiftUI

struct EditNavigation: View {
    @ObservedObject var editVM: EditTmpViewModel
    @Environment(\.dismiss) var dismiss
    
    private let diameter: CGFloat = 40
    private let font = Poppin.semiBold.font(size: 20)
    
    var body: some View {
        ZStack {
            HStack(spacing: 12) {
                xButton
                Spacer()
                saveButton
            }
            
            eidtToast
                .opacity(editVM.toast.isPresent ? 1 : 0)
                .animation(.easeInOut(duration: 0.5), value: editVM.toast.isPresent)
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
    }
    
    private var xButton: some View {
        Button {
            dismiss()
        } label: {
            Image(systemName: "xmark")
                .font(font)
                .foregroundColor(.white)
                .frame(width: diameter, height: diameter)
        }
    }
    
    private var saveButton: some View {
        Button {
            editVM.send(.saveButtonTapped)
        } label: {
            Image(systemName: "square.and.arrow.up")
                .font(font)
                .foregroundColor(.white)
                .frame(width: diameter, height: diameter)
        }
    }
    
    private var eidtToast: some View {
        Text(editVM.toast.text)
            .font(Poppin.medium.font(size: 12))
    }
}
