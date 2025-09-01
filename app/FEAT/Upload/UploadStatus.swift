import SwiftUI

struct UploadStatus: View {
    @ObservedObject var uploadVM: UploadViewModel
    
    private let size: CGFloat = 40
    private let line: CGFloat = 5
    
    var body: some View {
        Button(action: action, label: label)
        .disabled(uploadVM.loadingStatus != .none)
        .onChange(of: uploadVM.loadingStatus, onChanged)
    }
    
    private func action() {
        uploadVM.send(.uploadButtonTapped)
    }
    
    private func label() -> some View {
        ZStack {
            switch uploadVM.loadingStatus {
            case .none:
                UploadIcon()
                
            case .imageLoading:
                UploadLoading(size: size, line: line)
                
            case .completeLoading:
                UploadComplete(size: size, line: line)
            }
        }
        .animation(.bouncy, value: uploadVM.loadingStatus)
    }
    
    private func onChanged(_ oldStatus: UploadViewModel.Loading, _ newStatus: UploadViewModel.Loading) {
        if newStatus == .completeLoading {
            Task {
                try? await Task.sleep(for: .seconds(0.8))
                await MainActor.run {
                    uploadVM.send(.showEdit)
                }
            }
        }
    }
}

struct UploadIcon: View {
    var body: some View {
        VStack(spacing: 8) {
            image
            text
        }
    }
    
    private var image: some View {
        Image(systemName: "square.and.arrow.down.on.square")
            .font(Poppin.medium.font(size: 30))
            .foregroundColor(.mainWhite)
            .transition(.scale.combined(with: .opacity))
    }
    
    private var text: some View {
        Text("Choose an image to get started")
            .font(Poppin.medium.font(size: 12))
            .foregroundColor(.textGray)
    }
}

struct UploadLoading: View {
    let size: CGFloat
    let line: CGFloat
    
    @State private var spin = false
    
    var body: some View {
        ZStack {
            background
            loadingLine
        }
        .frame(width: size, height: size)
        .transition(.scale.combined(with: .opacity))
    }
    
    private var background: some View {
        Circle().stroke(Color.pointRed.opacity(0.18), lineWidth: line)
    }
    
    private var loadingLine: some View {
        Circle()
            .trim(from: 0.0, to: 0.6)
            .stroke(Color.pointRed, style: .init(lineWidth: line, lineCap: .round))
            .rotationEffect(.degrees(spin ? 360 : 0))
            .animation(.linear(duration: 1.2).repeatForever(autoreverses: false), value: spin)
            .onAppear { spin = true }
            .onDisappear { spin = false }
    }
}

struct UploadComplete: View {
    let size: CGFloat
    let line: CGFloat
    @State private var showRipple = false
    
    var body: some View {
        ZStack {
            checCircle
            rippleCircle
        }
        .frame(width: size, height: size)
        .onAppear { showRipple = true }
        .onDisappear { showRipple = false }
        .transition(.scale.combined(with: .opacity))
    }
    
    private var checCircle: some View {
        Circle()
            .fill(Color.pointRed)
            .overlay(checkIcon)
            .scaleEffect(showRipple ? 1.0 : 0.85)
            .animation(.spring(response: 0.3, dampingFraction: 0.8), value: showRipple)
    }
    
    private var checkIcon: some View {
        Image(systemName: "checkmark")
            .font(.system(size: 22, weight: .bold))
            .foregroundColor(.mainWhite)
    }
    
    private var rippleCircle: some View {
        Circle()
            .stroke(Color.pointRed.opacity(0.4), lineWidth: line)
            .scaleEffect(showRipple ? 1.28 : 1.0)
            .opacity(showRipple ? 0.0 : 1.0)
            .animation(.easeOut(duration: 0.8), value: showRipple)
    }
}


