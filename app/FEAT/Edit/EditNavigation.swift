import SwiftUI

struct EditNavigation: View {
    @ObservedObject var editVM: EditViewModel
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
            
            editToast
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
                .foregroundColor(editVM.filter.isEdited ? .white : .white.opacity(0.3))
                .frame(width: diameter, height: diameter)
        }
        .disabled(editVM.filter.disableSave)
    }
    
    private var editToast: some View {
        ZStack {
            if editVM.toast.isPresent {
                Text(editVM.toast.text)
                    .font(Poppin.medium.font(size: 12))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(eidtToastBackground)
                    .transition( eidtToastTransition)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: editVM.toast.isPresent)
    }
    
    
    private var eidtToastBackground: some View {
        Color.white.opacity(0.3)
            .cornerRadius(10)
    }
    
    private var eidtToastTransition: some Transition {
        .move(edge: .top)
        .combined(with: .opacity)
    }
}
