import SwiftUI

struct EditZoomableImage: View {
    let uiImage: UIImage
    
    @State private var scale: CGFloat = 1
    @State private var lastScale: CGFloat = 1
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    
    var body: some View {
        GeometryReader { geo in
            let screenSize = geo.size
            let imageAspect = uiImage.size.width / uiImage.size.height
            let displayHeight = screenSize.width / imageAspect
            
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .scaleEffect(scale)
                .offset(offset)
                .gesture(
                    MagnificationGesture()
                        .onChanged { value in
                            if value < lastScale && value < 1.2 {
                                withAnimation {
                                    scale = 1
                                }
                            } else {
                                scale = min(lastScale * value, 5)
                            }
                        }
                        .onEnded { _ in
                            withAnimation {
                                lastScale = scale
                                if lastScale == 1 {
                                    offset = .zero
                                    lastOffset = .zero
                                }
                            }
                        }
                )
                .simultaneousGesture(
                    DragGesture()
                        .onChanged { g in
                            var newOffset = CGSize(
                                width: lastOffset.width + g.translation.width,
                                height: lastOffset.height + g.translation.height
                            )
                            
                            // 확대된 이미지 크기 계산
                            let imgW = screenSize.width * scale
                            let imgH = displayHeight * scale
                            
                            // 이동 가능한 최대 범위
                            let maxX = max((imgW - screenSize.width) / 2, 0)
                            let maxY = max((imgH - screenSize.height) / 2, 0)
                            
                            // clamp
                            newOffset.width = min(max(newOffset.width, -maxX), maxX)
                            newOffset.height = min(max(newOffset.height, -maxY), maxY)
                            
                            offset = newOffset
                        }
                        .onEnded { _ in
                            lastOffset = offset
                        }
                )
        }
    }
}
