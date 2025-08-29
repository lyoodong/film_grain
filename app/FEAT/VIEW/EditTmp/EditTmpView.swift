import SwiftUI
import Photos
import PhotosUI

struct EditTmpView: View {
    @ObservedObject var editVM: EditTmpViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            if let uiImage = editVM.displayImage {
                ZStack {
                    EditZoomableImage(uiImage: uiImage)
                    VStack {
                        EditNavigation(editVM: editVM)
                        Spacer()
                    }
                }
                
                AICircularButton(size: 60) {
                    editVM.send(.aiButtonTapped)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.bg)
        .onAppear {
            editVM.send(.onAppear)
        }
    }
}


import SwiftUI

struct AICircularButton: View {
    var size: CGFloat = 64
    var action: () -> Void

    @State private var spin = false
    @State private var pulse = false
    @State private var shine = false

    private var iconName: String {
        return "sparkles"
    }

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.mainRed.opacity(0.95),
                                Color.mainRed.opacity(0.75),
                                Color.mainRed.opacity(0.55)
                            ],
                            center: .center,
                            startRadius: 4,
                            endRadius: size
                        )
                    )
                    .overlay(
                        Circle()
                            .stroke(
                                AngularGradient(
                                    gradient: Gradient(colors: [
                                        Color.white.opacity(0.35),
                                        Color.white.opacity(0.0),
                                        Color.white.opacity(0.35)
                                    ]),
                                    center: .center
                                ),
                                lineWidth: 2
                            )
                            .rotationEffect(.degrees(spin ? 360 : 0))
                            .animation(.linear(duration: 3.0).repeatForever(autoreverses: false), value: spin)
                    )
                    .overlay(
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        .white.opacity(0.0),
                                        .white.opacity(0.35),
                                        .white.opacity(0.0)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .rotationEffect(.degrees(shine ? 360 : 0))
                            .blendMode(.screen)
                            .opacity(0.6)
                            .mask(Circle())
                            .animation(.linear(duration: 2.2).repeatForever(autoreverses: false), value: shine)
                    )
                    .scaleEffect(pulse ? 1.0 : 0.98)
                    .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: pulse)

                Image(systemName: iconName)
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.white, Color.white.opacity(0.85))
                    .font(.system(size: size * 0.44, weight: .semibold))
                    .shadow(color: .white.opacity(0.35), radius: 6, x: 0, y: 0)
            }
            .frame(width: size, height: size)
            .background(
                Circle()
                    .fill(Color.clear)
                    .shadow(color: Color.mainRed.opacity(0.45), radius: 14, x: 0, y: 6)
            )
        }
        .buttonStyle(PressScaleButtonStyle())
        .onAppear {
            spin = true
            pulse = true
            shine = true
        }
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
