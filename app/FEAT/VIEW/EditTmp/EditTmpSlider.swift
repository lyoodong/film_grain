import SwiftUI

enum SliderType {
    case grainAlpha
    case grainScale
    
    var title: String {
        switch self {
        case .grainAlpha:
            return "Alpha"
        case .grainScale:
            return "Scale"
        }
    }
    
    var range: ClosedRange<Double> {
        switch self {
        case .grainAlpha:
            return 0...1
        case .grainScale:
            return 1...3
        }
    }
    
    var step: Double {
        switch self {
        case .grainAlpha:
            return 0.01
        case .grainScale:
            return 0.01
        }
    }
    
    var valueFormat: String {
        return "%.2f"
    }
}

struct EditTmpSlider: View {
    let type: SliderType
    let height: CGFloat = 60
    let bgColor: Color = .clear
    let value: Double
    let onChanged: (Double) -> ()
    
    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            sliderMeta
            slider
        }
        .frame(height: height)
        .padding(.horizontal, 24)
    }
    
    private var sliderMeta: some View {
        HStack() {
            title
            Spacer()
            valueText
        }
    }
    
    private var title: some View {
        Text(type.title)
    }
    
    private var valueText: some View {
        Text(String(format: "%.2f", value))
    }
    
    private var slider: some View {
        CustomSlider(
            value: Binding(
                get: { value },
                set: onChanged
            ),
            range: type.range,
            step: type.step
        )
        .background(bgColor)
    }
}
