import SwiftUI

struct EditUndoRedoBar: View {
    @ObservedObject var editVM: EditViewModel
    
    var body: some View {
        HStack {
            undoButton
            Spacer()
            fullImageButton
            Spacer()
            redoButton
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }
    
    private var fullImageButton: some View {
        Button(action: fullImageButtonAction, label: fullImageButtonLabel)
            .disabled(editVM.isDisableFullImageButton)
    }
    
    private func fullImageButtonAction() {
        impact()
        editVM.send(.fullImageButtonTapped)
    }
    
    private func fullImageButtonLabel() ->some View {
        Text("Full Image")
            .font(Poppin.medium.font(size: 12))
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(fullImageButtonBackground)
            .foregroundColor(editVM.isDisableFullImageButton ? .white.opacity(0.3) : .white)
    }
    
    private var fullImageButtonBackground: some View {
        Color.white.opacity(0.3)
            .cornerRadius(10)
    }
    
    private var undoButton: some View {
        Button(action: undoButtonAction, label: undoIcon)
            .disabled(editVM.filter.disableUndo)
    }
    
    private func undoButtonAction() {
        impact()
        editVM.send(.undoButtonTapped)
    }
    
    private func undoIcon() ->some View {
        Image(systemName: "arrow.uturn.backward")
            .font(.system(size: 15, weight: .semibold))
            .foregroundColor(editVM.filter.disableUndo ? .textGray : .pointRed)
            .frame(width: 40, height: 40)
    }
    
    private var redoButton: some View {
        Button(action: redoButtonAction, label: redoIcon)
            .disabled(editVM.filter.disableRedo)
    }
    
    private func redoButtonAction() {
        impact()
        editVM.send(.redoButtonTapped)
    }
    
    private func redoIcon() -> some View {
        Image(systemName: "arrow.uturn.forward")
            .font(.system(size: 15, weight: .semibold))
            .foregroundColor(editVM.filter.disableRedo ? .textGray : .pointRed)
            .frame(width: 40, height: 40)
    }
    
    private func impact() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
}

