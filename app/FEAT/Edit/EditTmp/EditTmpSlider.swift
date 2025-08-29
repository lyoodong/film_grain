import SwiftUI

enum SliderType {
    case grainAlpha
    case grainScale
    case contrast
    case temperture
    case threshold
    case brightColorAlpha
    case darkColorAlpha
    
    var title: String {
        switch self {
        case .grainAlpha:
            return "Alpha"
        case .grainScale:
            return "Scale"
        case .contrast:
            return "Contrast"
        case .temperture:
            return "Temperture"
        case .threshold:
            return "Threshold"
        case .brightColorAlpha:
            return "Bright Alpha"
        case .darkColorAlpha:
            return "Dark Alpha"
        }
    }
    
    var range: ClosedRange<Double> {
        switch self {
        case .grainAlpha:
            return 0...1
        case .grainScale:
            return 1...3
        case .contrast:
            return 0.8...1.2
        case .temperture:
            return 2000...10000
        case .threshold:
            return 0...1
        case .brightColorAlpha:
            return 0...1
        case .darkColorAlpha:
            return 0...1
        }
    }
    
    var step: Double {
        switch self {
        case .grainAlpha:
            return 0.01
        case .grainScale:
            return 0.01
        case .contrast:
            return 0.0001
        case .temperture:
            return 100
        case .threshold:
            return 0.01
        case .brightColorAlpha:
            return 0.01
        case .darkColorAlpha:
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
