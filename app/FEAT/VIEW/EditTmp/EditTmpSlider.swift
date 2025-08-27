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
            return 1...100
        case .grainScale:
            return 0...1
        }
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
        Text("\(Int(value))")
            .frame(width: 36)
    }
    
    private var slider: some View {
        CustomSlider(
            value: Binding(
                get: { value },
                set: onChanged
            ),
            range: type.range
        )
        .background(bgColor)
    }
}
