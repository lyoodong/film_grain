import SwiftUI

//struct UploadButton: View {
//    @ObservedObject var uploadVM: UploadViewModel
//    @State private var loadingProgress: CGFloat = 0
//    @State private var loadingOffset: CGFloat = -100
//
//    var body: some View {
//        Button {
//            uploadVM.send(.uploadButtonTapped)
//        } label: {
//            ZStack {
//                RoundedRectangle(cornerRadius: uploadVM.isLoading ? 0 : 16)
//                    .fill(uploadVM.isLoading ? Color.white : Color.mainRed)
//                    .frame(width: uploadVM.isLoading ? 200 : 100, height: uploadVM.isLoading ? 2 : 40)
//
//                if uploadVM.isLoading {
//                    RoundedRectangle(cornerRadius: 0)
//                        .fill(Color.mainRed)
//                        .frame(width: loadingProgress, height: 2)
//                        .offset(x: loadingOffset)
//                        .animation(.easeInOut(duration: 0.8), value: loadingProgress)
//                        .animation(.easeInOut(duration: 0.8), value: loadingOffset)
//                        .onAppear {
//                            startLoadingAnimation()
//                        }
//                }
//
//                if !uploadVM.isLoading {
//                    Image(systemName: "square.and.arrow.down.on.square")
//                        .font(.headline)
//                        .foregroundColor(.white)
//                }
//            }
//        }
//        .disabled(uploadVM.isLoading)
//        .animation(.bouncy, value: uploadVM.isLoading)
//    }
//
//    private func startLoadingAnimation() {
//        guard uploadVM.isLoading else { return }
//
//        Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { timer in
//            if !uploadVM.isLoading {
//                timer.invalidate()
//                return
//            }
//
//            withAnimation(.easeInOut(duration: 0.8)) {
//                loadingProgress = CGFloat.random(in: 40...160)
//                loadingOffset = CGFloat.random(in: -50...50)
//            }
//        }
//    }
//
//    private func stopLoadingAnimation() {
//        loadingProgress = 0
//        loadingOffset = -100
//    }
//}

struct UploadButton: View {
    @ObservedObject var uploadVM: UploadViewModel
    @State private var dotsAnimate = false
    
    var body: some View {
        Button {
            uploadVM.send(.uploadButtonTapped)
        } label: {
            ZStack {
                if uploadVM.isLoading {
                    HStack(spacing: 8) {
                        ForEach(0..<3) { i in
                            Circle()
                                .fill(Color.mainRed)
                                .frame(width: 10, height: 10)
                                .opacity(dotsAnimate ? 1.0 : 0.25)
                                .scaleEffect(dotsAnimate ? 1.0 : 0.8)
                                .animation(
                                    .easeInOut(duration: 0.6)
                                    .repeatForever(autoreverses: true)
                                    .delay(Double(i) * 0.2),
                                    value: dotsAnimate
                                )
                        }
                    }
                    .onAppear { dotsAnimate = true }
                    .onDisappear { dotsAnimate = false }
                    .transition(.scale.combined(with: .opacity))
                } else {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.mainRed)
                        .frame(width: 100, height: 40)
                        .overlay(
                            Image(systemName: "square.and.arrow.down.on.square")
                                .font(.headline)
                                .foregroundColor(.white)
                        )
                        .transition(.scale(scale: 0))
                }
            }
            // 모양/사이즈 전환 애니메이션
            .animation(.bouncy, value: uploadVM.isLoading)
        }
        .disabled(uploadVM.isLoading)
    }
}
