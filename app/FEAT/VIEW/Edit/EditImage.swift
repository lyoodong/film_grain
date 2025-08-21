import SwiftUI

struct EditImage: View {
    let image: UIImage
    
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    
    var body: some View {
        GeometryReader { proxy in
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .scaleEffect(scale)
                .offset(offset)
                .gesture(
                    // 핀치 줌
                    MagnificationGesture()
                        .onChanged { value in
                            self.scale = self.lastScale * value
                        }
                        .onEnded { value in
                            let newScale = self.lastScale * value
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                                if newScale < 1 {
                                    self.scale = 1
                                    self.lastScale = 1
                                    // 원래 크기로 돌아오면 드래그 오프셋도 초기화
                                    self.offset = .zero
                                    self.lastOffset = .zero
                                } else {
                                    self.scale = newScale
                                    self.lastScale = newScale
                                    // 확대 시 기본 오프셋 유지
                                }
                            }
                        }
                )
                .simultaneousGesture(
                    // 드래그 제스처: scale > 1 일 때만 적용
                    DragGesture()
                        .onChanged { value in
                            guard self.lastScale > 1 else { return }
                            // 뷰보다 이미지가 넓은 경우에만 움직이도록 (간단 체크)
                            let imgWidth = proxy.size.width * self.lastScale
                            let imgHeight = proxy.size.height * self.lastScale
                            if imgWidth > proxy.size.width || imgHeight > proxy.size.height {
                                self.offset = CGSize(
                                    width: self.lastOffset.width + value.translation.width,
                                    height: self.lastOffset.height + value.translation.height
                                )
                            }
                        }
                        .onEnded { _ in
                            guard self.lastScale > 1 else {
                                // 축소 상태라면 중앙 복원
                                withAnimation {
                                    self.offset = .zero
                                    self.lastOffset = .zero
                                }
                                return
                            }
                            // 확대 상태라면 최종 오프셋 저장
                            self.lastOffset = self.offset
                        }
                )
                .frame(width: proxy.size.width, height: proxy.size.height)
                .background(Color.black.opacity(0.001))
        }
    }
}
