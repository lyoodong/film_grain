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
                aiButton
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
    
    private var aiButton: some View {
        Button {
            editVM.send(.aiButtonTapped)
        } label: {
            Image(systemName: "apple.intelligence")
                .font(font)
                .foregroundColor(.pointRed)
                .rotationEffect(.degrees(editVM.isAIAnalyzing ? 360.0 : 0.0))
                .animation(aiAnimation, value: editVM.isAIAnalyzing)
                .frame(width: diameter, height: diameter)
        }
    }
    
    private var aiAnimation: Animation {
        editVM.isAIAnalyzing ? foreverAnimation : stopAnimation
    }
    
    private var foreverAnimation: Animation {
        .linear(duration: 1.0)
        .repeatForever(autoreverses: false)
    }
    
    private var stopAnimation: Animation {
        .linear(duration: 0)
    }
    
    private var eidtToast: some View {
        Text(editVM.toast.text)
            .font(Poppin.medium.font(size: 12))
    }
}

struct PressScaleButtonStyle: ButtonStyle {
    var pressedScale: CGFloat = 0.96
    var pressedBGColor: Color = .textGray
    let diameter: CGFloat
    
    init(_ diameter: CGFloat) {
        self.diameter = diameter
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                Circle()
                    .fill(pressedBGColor)
                    .frame(width: diameter, height: diameter)
                    .opacity(configuration.isPressed ? 1 : 0)
            )
            .contentShape(Circle())
            .scaleEffect(configuration.isPressed ? pressedScale : 1.0)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}
