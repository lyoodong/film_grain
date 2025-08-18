import SwiftUI

struct EditSlider: View {
    let name: String
    let value: Double
    let range: ClosedRange<Double>
    let step: Double
    let onValueChanged: (Double) -> Void

    var body: some View {
        HStack {
            Text("\(name) \(Int(value))")
            
            Slider(
                value: Binding(
                    get: { value },
                    set: onValueChanged
                ),
                in: range,
                step: step
            )
        }
    }
}
