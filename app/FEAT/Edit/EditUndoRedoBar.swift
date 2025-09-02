import SwiftUI

struct EditUndoRedoBar: View {
    @ObservedObject var editVM: EditViewModel
    
    var body: some View {
        HStack {
            undoButton
            Spacer()
            redoButton
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }
    
    private var undoButton: some View {
        Button(action: undoButtonAction, label: undoIcon)
    }
    
    private func undoButtonAction() {
        impact()
    }
    
    private func undoIcon() ->some View {
        Image(systemName: "arrow.uturn.backward")
            .font(.system(size: 15, weight: .semibold))
            .frame(width: 40, height: 40)
    }
    
    private var redoButton: some View {
        Button(action: redoButtonAction, label: redoIcon)
    }
    
    private func redoButtonAction() {
        impact()
    }
    
    private func redoIcon() -> some View {
        Image(systemName: "arrow.uturn.forward")
            .font(.system(size: 15, weight: .semibold))
            .frame(width: 40, height: 40)
    }
    
    private func impact() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
}

