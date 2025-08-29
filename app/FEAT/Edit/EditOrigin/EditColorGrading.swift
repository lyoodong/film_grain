import SwiftUI

struct EditColorGrading: View {
    @ObservedObject var editVM: EditViewModel

    var body: some View {
        VStack {
            colorGradingToggle
            
            if editVM.isColorGrading {
                thresholdSlider
                brightBaseSlider
                darkBaseSlider
            }
        }
    }
    
    private var colorGradingToggle: some View {
        Toggle(isOn: Binding(get: { editVM.isColorGrading },
                             set: { editVM.send(.isOnColorGrading($0))}))
        { Text("ColorGrading") }
    }
    
    private var thresholdSlider: some View {
        EditSlider(
            name: "CG threshold",
            value: editVM.threshold,
            range: 0...1,
            step: 0.01
        ) { editVM.send(.thresholdChanged($0)) }
    }
    
    private var brightBaseSlider: some View {
        EditSlider(
            name: "ORANGE",
            value: editVM.brightAlpha,
            range: 0...1,
            step: 0.01
        ) { editVM.send(.brightAlphaChanged($0)) }
    }
    
    private var darkBaseSlider: some View {
        EditSlider(
            name: "TEAL",
            value: editVM.darkAlpha,
            range: 0...1,
            step: 0.01
        ) { editVM.send(.darkAlphaChanged($0)) }
    }
}
