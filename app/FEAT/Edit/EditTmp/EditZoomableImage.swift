import SwiftUI

struct EditZoomableImage: View {
    @ObservedObject var editVM: EditTmpViewModel
    
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    
    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let height = proxy.size.height
            
            if let uiImage = editVM.displayImage {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .scaleEffect(scale)
                    .offset(offset)
                    .frame(width: width, height: height, alignment: .center)
                    .gesture(magnifyGesture(proxy: proxy, aspect: uiImage.aspectRatio).simultaneously(with: dragGesture(proxy: proxy, aspect: uiImage.aspectRatio)))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .clipped()
            }
        }
    }
    
    private func magnifyGesture(proxy: GeometryProxy, aspect: CGFloat) -> some Gesture {
        MagnifyGesture()
            .onChanged { value in
                withAnimation(.interactiveSpring(duration: 0.3)) {
                    scale = scaleGestureOnChanged(value.magnification)
                }
            }
            .onEnded { _ in
                withAnimation(.interactiveSpring(duration: 0.3)) {
                    scaleGestureOnEnded(proxy: proxy, aspect: aspect)
                }
            }
    }
    
    private func dragGesture(proxy: GeometryProxy, aspect: CGFloat) -> some Gesture {
        return DragGesture()
            .onChanged { value in
                offset = offsetGestureOnChanged(value.translation, proxy: proxy, aspect: aspect)
            }
            .onEnded { _ in
                offsetGestureOnEnded()
            }
    }
    
    private func scaleGestureOnChanged(_ scale: CGFloat) -> CGFloat {
        let newScale = scale * lastScale
        let adjustedScale = min(max(newScale, 0.9), 5)
        return adjustedScale
    }
    
    private func scaleGestureOnEnded(proxy: GeometryProxy, aspect: CGFloat) {
        scale = max(scale, 1)
        lastScale = scale
        
        if scale == 1 {
            offset = .zero
            lastOffset = .zero
        } else {
            offset = fitOffset(offset, proxy: proxy, aspect: aspect)
            lastOffset = offset
        }
    }
    
    private func offsetGestureOnChanged(_ offset: CGSize, proxy: GeometryProxy, aspect: CGFloat) -> CGSize {
        guard scale > 1 else { return .zero }

        return fitOffset(offset, proxy: proxy, aspect: aspect)
    }
    
    private func offsetGestureOnEnded() {
        lastOffset = offset
    }
    
    private func fitOffset(_ offset: CGSize, proxy: GeometryProxy, aspect: CGFloat) -> CGSize {
        let container = proxy.size
        let fit: CGSize = (container.width / container.height > aspect)
        ? .init(width: container.height * aspect, height: container.height)
        : .init(width: container.width, height: container.width / aspect)

        let sw = fit.width  * scale
        let sh = fit.height * scale

        let maxX = max(0, (sw - container.width)  / 2)
        let maxY = max(0, (sh - container.height) / 2)

        let rawX = offset.width  + lastOffset.width
        let rawY = offset.height + lastOffset.height

        let x = clamp(value: rawX, lower: -maxX, upper: maxX)
        let y = clamp(value: rawY, lower: -maxY, upper: maxY)

        return .init(width: x, height: y)
    }
    
    private func clamp(value: CGFloat, lower: CGFloat, upper: CGFloat) -> CGFloat {
        return min(max(value, lower), upper)
    }
}
