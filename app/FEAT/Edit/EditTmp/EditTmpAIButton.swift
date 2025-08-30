import SwiftUI

struct EditTmpAIButton: View {
    @ObservedObject var editVM: EditTmpViewModel
    
    var body: some View {
        Button {
            editVM.send(.aiButtonTapped)
        } label: {
            ZStack(alignment: .center) {
                background
                
                if editVM.hadAIbuttonTextAnimated { icon }
                else { text }
            }
        }
        .animation(.easeInOut, value: editVM.hadAIbuttonTextAnimated)
        .buttonStyle(PressScaleButtonStyle())
    }
    
    private var background: some View {
        Capsule()
            .fill(.ultraThinMaterial)
            .frame(width: editVM.hadAIbuttonTextAnimated ? 40: 180 , height: 40)
    }
    
    private var icon: some View {
        Image(systemName: "apple.intelligence")
            .font(Poppin.medium.font(size: 16))
            .foregroundColor(.white)
            .rotationEffect(.degrees(editVM.isAIAnalyzing ? 360.0 : 0.0))
            .animation(editVM.isAIAnalyzing ? foreverAnimation : stopAnimation, value:  editVM.isAIAnalyzing)
    }
    
    private var foreverAnimation: Animation {
        .linear(duration: 1.0)
        .repeatForever(autoreverses: false)
    }
    
    private var stopAnimation: Animation {
        .linear(duration: 0)
    }

    private var text: some View {
        Text("AI Generate")
            .font(Poppin.medium.font(size: 16))
    }
}

struct PressScaleButtonStyle: ButtonStyle {
    var pressedScale: CGFloat = 0.96
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? pressedScale : 1.0)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}


