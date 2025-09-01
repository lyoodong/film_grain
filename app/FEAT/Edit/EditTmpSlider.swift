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
        switch self {
        case .temperture:
            return "%.0f"
        default:
            return "%.2f"
        }
    }
}

struct EditTmpSlider: View {
    let type: SliderType
    let value: Double
    let onChanged: (Double) -> ()

    let color: Color
    let height: CGFloat
    let font: Font
    let colorSelected: (Color) -> Void

    init(
        type: SliderType,
        value: Double,
        color: Color = .clear,
        height: CGFloat = 60,
        font: Font = Poppin.medium.font(size: 12),
        colorSelected: @escaping (Color) -> Void = { _ in },
        onChanged: @escaping (Double) -> Void
    ) {
        self.type = type
        self.value = value
        self.color = color
        self.height = height
        self.font = font
        self.colorSelected = colorSelected
        self.onChanged = onChanged
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            if type == .brightColorAlpha || type == .darkColorAlpha {
                HStack(spacing: 16) {
                    colorCirlce
                    slider
                }
            } else {
                VStack {
                    sliderMeta
                    slider
                }
            }
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
            .font(font)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(background)
    }
    
    private var valueText: some View {
        Text(String(format: type.valueFormat, value))
            .font(font)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(background)
    }
    
    private var background: some View {
        Capsule().fill(Color.sheetGray)
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
        .background(.clear)
    }
    
    private var colorCirlce: some View {
        ColorPicker(
            "",
            selection: Binding(
                get: { color },
                set: { colorSelected($0)}
            ),
            supportsOpacity: false
        )
        .labelsHidden()
        .frame(width: 24, height: 24)
    }
}
