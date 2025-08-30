import SwiftUI

struct UploadStatus: View {
    @ObservedObject var uploadVM: UploadViewModel
    
    private let size: CGFloat = 40
    private let line: CGFloat = 5
    
    var body: some View {
        Button {
            uploadVM.send(.uploadButtonTapped)
        } label: {
            ZStack {
                switch uploadVM.loadingStatus {
                case .none:
                    UploadButton()
                    
                case .imageLoading:
                    UploadLoading(size: size, line: line)
                    
                case .completeLoading:
                    UploadComplete(size: size, line: line)
                }
            }
            .animation(.bouncy, value: uploadVM.loadingStatus)
        }
        .disabled(uploadVM.loadingStatus != .none)
        .onChange(of: uploadVM.loadingStatus) { _, status in
            if status == .completeLoading {
                Task {
                    try? await Task.sleep(for: .seconds(0.8))
                    await MainActor.run {
                        uploadVM.send(.showEdit)
                    }
                }
            }
        }
    }
}

struct UploadButton: View {
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "square.and.arrow.down.on.square")
                .font(Poppin.medium.font(size: 30))
                .foregroundColor(.mainWhite)
                .transition(.scale.combined(with: .opacity))
            
            Text("Choose an image to get started")
                .font(Poppin.medium.font(size: 12))
                .foregroundColor(.textGray)
        }
    }
}

struct UploadLoading: View {
    let size: CGFloat
    let line: CGFloat
    @State private var spin = false
    
    var body: some View {
        ZStack {
            Circle().stroke(Color.pointRed.opacity(0.18), lineWidth: line)
            
            Circle()
                .trim(from: 0.0, to: 0.6)
                .stroke(Color.pointRed, style: .init(lineWidth: line, lineCap: .round))
                .rotationEffect(.degrees(spin ? 360 : 0))
                .animation(.linear(duration: 1.2).repeatForever(autoreverses: false), value: spin)
                .onAppear { spin = true }
                .onDisappear { spin = false }
        }
        .frame(width: size, height: size)
        .transition(.scale.combined(with: .opacity))
    }
}

struct UploadComplete: View {
    let size: CGFloat
    let line: CGFloat
    @State private var successRipple = false
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.pointRed)
                .overlay(
                    Image(systemName: "checkmark")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.mainWhite)
                )
                .scaleEffect(successRipple ? 1.0 : 0.85)
                .animation(.spring(response: 0.3, dampingFraction: 0.8), value: successRipple)
            
            Circle()
                .stroke(Color.pointRed.opacity(0.4), lineWidth: line)
                .scaleEffect(successRipple ? 1.28 : 1.0)
                .opacity(successRipple ? 0.0 : 1.0)
                .animation(.easeOut(duration: 0.8), value: successRipple)
        }
        .frame(width: size, height: size)
        .onAppear { successRipple = true }
        .onDisappear { successRipple = false }
        .transition(.scale.combined(with: .opacity))
    }
}


