import SwiftUI

struct EditToneTap: View {
    @ObservedObject var editVM: EditViewModel
    
    var body: some View {
        VStack {
            if editVM.filter.isOnBrightColor || editVM.filter.isOndarkColor { thresholdSlider }
            highlightColor
            if editVM.filter.isOnBrightColor { highlighAlphaSlider }
            shadowColor
            if editVM.filter.isOndarkColor { shadowAlphaSlider }
        }
    }
    
    private var thresholdSlider: some View {
        EditSlider(
            type: .threshold,
            value: editVM.filter.threshold
        ) {
            editVM.send(.thresholdChanged($0))
        }
    }
    
    private var highlightColor: some View {
        ColorToggleStack(
            title: "Highlight",
            isOn: Binding(
                get: { editVM.filter.isOnBrightColor },
                set: { editVM.send(.highlightToggle($0)) }
            )
        )
    }
    
    private var highlighAlphaSlider: some View {
        EditSlider(
            type: .brightColorAlpha,
            value: editVM.filter.brightAlpha,
            color: editVM.filter.brightColor,
            colorSelected: { editVM.send(.highlightColorButtonTapped($0)) },
            onChanged: { editVM.send(.brightColorAlphaChanged($0)) }
        )
    }
    
    private var shadowColor: some View {
        ColorToggleStack(
            title: "Shadow",
            isOn: Binding(
                get: { editVM.filter.isOndarkColor },
                set: { editVM.send(.shadowToggle($0)) }
            )
        )
    }
    
    private var shadowAlphaSlider: some View {
        EditSlider(
            type: .darkColorAlpha,
            value: editVM.filter.darkAlpha,
            color: editVM.filter.darkColor,
            colorSelected: { editVM.send(.shadowColorButtonTapped($0)) },
            onChanged: { editVM.send(.darkColorAlphaChanged($0)) }
        )
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

