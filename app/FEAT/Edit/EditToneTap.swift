import SwiftUI

struct EditToneTap: View {
    @ObservedObject var editVM: EditViewModel
    
    var body: some View {
        VStack {
            if editVM.filter.param.isOnBrightColor || editVM.filter.param.isOndarkColor { thresholdSlider }
            highlightColor
            if editVM.filter.param.isOnBrightColor { highlighAlphaSlider }
            shadowColor
            if editVM.filter.param.isOndarkColor { shadowAlphaSlider }
        }
    }
    
    private var thresholdSlider: some View {
        EditSlider(
            type: .threshold,
            value: editVM.filter.param.threshold,
            onChanged: thresholdSliderOnChanged,
            onEnded: thresholdSliderOnEnded
        )
    }
    
    private func thresholdSliderOnChanged(_ value: Double) {
        editVM.send(.thresholdChanged(value))
    }
    
    private func thresholdSliderOnEnded(_ value: Double) {
        editVM.send(.thresholdEnded(value))
    }
    
    private var highlightColor: some View {
        ColorToggleStack(
            title: "Highlight",
            isOn: Binding(
                get: { editVM.filter.param.isOnBrightColor },
                set: { editVM.send(.highlightToggle($0)) }
            )
        )
    }
    
    private var highlighAlphaSlider: some View {
        EditSlider(
            type: .brightColorAlpha,
            value: editVM.filter.param.brightAlpha,
            color: editVM.filter.param.brightColor,
            colorSelected: { editVM.send(.highlightColorButtonTapped($0)) },
            onChanged: brightAlphaSliderOnChanged,
            onEnded: brightAlphaSliderOnEnded
        )
    }
    
    private func brightAlphaSliderOnChanged(_ value: Double) {
        editVM.send(.brightColorAlphaChanged(value))
    }
    
    private func brightAlphaSliderOnEnded(_ value: Double) {
        editVM.send(.brightColorAlphaEnded(value))
    }
    
    private var shadowColor: some View {
        ColorToggleStack(
            title: "Shadow",
            isOn: Binding(
                get: { editVM.filter.param.isOndarkColor },
                set: { editVM.send(.shadowToggle($0)) }
            )
        )
    }
    
    private var shadowAlphaSlider: some View {
        EditSlider(
            type: .darkColorAlpha,
            value: editVM.filter.param.darkAlpha,
            color: editVM.filter.param.darkColor,
            colorSelected: { editVM.send(.shadowColorButtonTapped($0)) },
            onChanged: darkAlphaSliderOnChanged,
            onEnded: darkAlphaSliderOnEnded
        )
    }
    
    private func darkAlphaSliderOnChanged(_ value: Double) {
        editVM.send(.darkColorAlphaChanged(value))
    }
    
    private func darkAlphaSliderOnEnded(_ value: Double) {
        editVM.send(.darkColorAlphaEnded(value))
    }
}


struct ColorToggleStack: View {
    let title: String
    @Binding var isOn: Bool
    
    private let font = Poppin.semiBold.font(size: 12)
    
    var body: some View {
        HStack() {
            text
            Spacer()
            toggle
        }
        .padding(.horizontal, 16)
    }
    
    private var text: some View {
        Text(title)
            .font(font)
    }
    
    private var toggle: some View {
        Toggle(isOn: $isOn, label: { })
            .labelsHidden()
            .tint(.white.opacity(0.6))
            .scaleEffect(0.9)
    }
}

