import SwiftUI

struct CustomSlider: View {
    @Binding var value: Double
    let range: ClosedRange<Double>
    let step: Double

    @GestureState private var isDragging = false

    var body: some View {
        GeometryReader { geo in
            let width = max(1, geo.size.width)
            let progress = (value - range.lowerBound) / (range.upperBound - range.lowerBound)
            let x = progress * width

            VStack {
                Spacer()
                ZStack(alignment: .leading) {
                    BaseTrack()
                        .frame(height: 16)
                    ProgressedTrack(x: x)
                    Thumb(
                        value: $value,
                        isDragging: isDragging,
                        x: x,
                        range: range
                    )
                }
                .gesture(dragGesture(width))
                Spacer()
            }
        }
    }
    
    private func dragGesture(_ width: CGFloat) -> some Gesture {
        return DragGesture(minimumDistance: 0)
            .updating($isDragging) { _, s, _ in s = true }
            .onChanged { g in
                let px = min(max(g.location.x, 0), width)
                let t  = px / width
                let v  = range.lowerBound + Double(t) * (range.upperBound - range.lowerBound)
                value  = snap(v, to: step, in: range)
            }
            .onEnded { g in
                let px = min(max(g.location.x, 0), width)
                let t  = px / width
                let v  = range.lowerBound + Double(t) * (range.upperBound - range.lowerBound)
                value  = snap(v, to: step, in: range)
            }
    }
    
    private func snap(_ v: Double, to step: Double, in range: ClosedRange<Double>) -> Double {
        guard step > 0 else { return min(max(v, range.lowerBound), range.upperBound) }
        let l = range.lowerBound
        let snapped = l + (round((v - l) / step) * step)
        return min(max(snapped, range.lowerBound), range.upperBound)
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
            .fill(Color.white)
            .frame(width: max(0, x), height: 2)
    }
}

private struct Thumb: View {
    @Binding var value: Double
    let isDragging: Bool
    let x: CGFloat
    let range: ClosedRange<Double>
    
    var size: CGFloat {
        return isDragging ? 16 : 12
    }
    
    var shadowRadius: CGFloat {
        return isDragging ? 2 : 0
    }
    
    var centeredOffeset: CGFloat {
        return x - (isDragging ? 8 : 6)
    }

    var body: some View {
        Circle()
            .fill(Color.white)
            .frame(width: size, height: size)
            .shadow(radius: shadowRadius)
            .offset(x: centeredOffeset)
    }
}

