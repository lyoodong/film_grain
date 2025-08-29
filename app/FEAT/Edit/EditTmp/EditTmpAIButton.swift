import SwiftUI

struct EditTmpAIButton: View {
    @ObservedObject var editVM: EditTmpViewModel
    @State private var spin = false
    
    var body: some View {
        Button {
            editVM.send(.aiButtonTapped)
        } label: {
            ZStack(alignment: .center) {
                Capsule()
                    .fill(Color.mainBlack)
                    .frame(width: editVM.isAIAnalyzing ? 50 : 180, height: 50)
                
                HStack {
                    if !editVM.isAIAnalyzing {
                        Text("AI Generate")
                            .font(Poppin.medium.font(size: 16))
                    } else {
                        Image(systemName: "apple.intelligence")
                            .rotationEffect(.degrees(spin ? 360 : 0))
                            .animation(.linear(duration: 1.2).repeatForever(autoreverses: false), value: spin)
                            .font(Poppin.medium.font(size: 16))
                            .foregroundColor(.white)
                            .onAppear { spin = true }
                            .onDisappear { spin = false }
                    }
                }
            }
        }
        .buttonStyle(PressScaleButtonStyle())
        .animation(.easeInOut, value: editVM.isAIAnalyzing)
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


