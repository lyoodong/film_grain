import SwiftUI

struct CustomSlider: View {
    @Binding var value: Double
    let range: ClosedRange<Double>
    
    @GestureState private var isDragging = false
    
    var body: some View {
        GeometryReader { geo in
            let width = max(1, geo.size.width) // 최소 1 보장
            let rawProgress = (value - range.lowerBound) / (range.upperBound - range.lowerBound)
            let progress = min(max(rawProgress, 0), 1) // 0...1 클램프
            let thumbX = progress * width
            
            VStack {
                Spacer()
                ZStack(alignment: .leading) {
                    BaseTrack()
                    ProgressedTrack(x: thumbX)
                    thumb(
                        isDragging: isDragging,
                        value: $value,
                        x: thumbX,
                        trackWidth: width,
                        range: range
                    )
                }
                Spacer()
            }
        }
    }
}

private struct BaseTrack: View {
    var body: some View {
        Capsule()
            .fill(Color.gray.opacity(0.4))
            .frame(height: 2)
    }
}

private struct ProgressedTrack: View {
    let x: CGFloat
    
    var body: some View {
        Capsule()
            .fill(Color.gray.opacity(0.4))
            .frame(width: x, height: 2)
    }
}

private struct thumb: View {
    @GestureState var isDragging: Bool
    @Binding var value: Double
    let x: CGFloat
    let trackWidth: CGFloat
    let range: ClosedRange<Double>
    
    var size: CGFloat {
        return isDragging ? 16 : 12
    }
    
    var shadowRadius: CGFloat {
        return isDragging ? 2 : 0
    }
    
    var adjustCenterOffeset: CGFloat {
        return x - (isDragging ? 10 : 6)
    }
    
    var body: some View {
        Circle()
            .fill(Color.white)
            .frame(width: size, height: size)
            .shadow(radius: shadowRadius)
            .offset(x: adjustCenterOffeset)
            .gesture(dragGestrure)
    }
    
    private var dragGestrure: some Gesture {
        DragGesture()
            .updating($isDragging) { _, state, _ in
                state = true
            }
            .onChanged { drag in
                let newValue = range.lowerBound + Double(drag.location.x / trackWidth) * (range.upperBound - range.lowerBound)
                value = min(max(newValue, range.lowerBound), range.upperBound)
            }
    }
}
