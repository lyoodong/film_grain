import SwiftUI

struct EditZoomableImage: View {
    let uiImage: UIImage
    
    @State private var scale: CGFloat = 1
    @State private var lastScale: CGFloat = 1
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    
    var body: some View {
        GeometryReader { proxy in
            let container = proxy.size
            let imgAspect = uiImage.size.width / uiImage.size.height
            let containerAspect = container.width / container.height
            
            let baseSize: CGSize = {
                if imgAspect > containerAspect {
                    let w = container.width
                    let h = w / imgAspect
                    return .init(width: w, height: h)
                } else {
                    let h = container.height
                    let w = h * imgAspect
                    return .init(width: w, height: h)
                }
            }()
            
            HStack {
                Spacer()
                
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .scaleEffect(scale)
                    .offset(offset)
                    .contentShape(Rectangle()) // 제스처 히트영역
                    .gesture(
                        MagnificationGesture()
                            .onChanged { value in
                                let newScale = min(max(lastScale * value, 1), 5)
                                if newScale < scale {
                                    scale = newScale
                                    offset = clampedOffset(offset,
                                                           scale: newScale,
                                                           base: baseSize,
                                                           container: container)
                                } else {
                                    scale = newScale
                                    offset = clampedOffset(offset,
                                                           scale: newScale,
                                                           base: baseSize,
                                                           container: container)
                                }
                            }
                            .onEnded { _ in
                                withAnimation(.interactiveSpring) {
                                    lastScale = scale
                                    if lastScale <= 1.1 {
                                        scale = 1
                                        offset = .zero
                                        lastOffset = .zero
                                    } else {
                                        offset = clampedOffset(offset,
                                                               scale: scale,
                                                               base: baseSize,
                                                               container: container)
                                        lastOffset = offset
                                    }
                                }
                            }
                    )
                    .simultaneousGesture(
                        DragGesture()
                            .onChanged { g in
                                guard scale > 1 else {
                                    offset = .zero
                                    return
                                }
                                let proposed = CGSize(
                                    width: lastOffset.width + g.translation.width,
                                    height: lastOffset.height + g.translation.height
                                )
                                offset = clampedOffset(proposed,
                                                       scale: scale,
                                                       base: baseSize,
                                                       container: container)
                            }
                            .onEnded { _ in
                                lastOffset = offset
                            }
                    )
                    .cornerRadius(16)
                
                Spacer()
            }
        }
    }
    
    /// 현재 스케일에서 이동 가능한 offset 범위로 보정.
    private func clampedOffset(_ current: CGSize,
                               scale: CGFloat,
                               base: CGSize,
                               container: CGSize) -> CGSize {
        let scaledW = base.width  * scale
        let scaledH = base.height * scale
        
        // 각 축에서 남는 여백의 절반(이동 허용치)
        let maxX = max((scaledW - container.width) / 2, 0)
        let maxY = max((scaledH - container.height) / 2, 0)
        
        // 이미지가 컨테이너보다 작아진 축은 중앙 고정(0)
        let x = (maxX == 0) ? 0 : min(max(current.width,  -maxX),  maxX)
        let y = (maxY == 0) ? 0 : min(max(current.height, -maxY),  maxY)
        
        return CGSize(width: x, height: y)
    }
}
