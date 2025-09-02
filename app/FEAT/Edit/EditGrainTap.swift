import SwiftUI

struct EditGrainTap: View {
    @ObservedObject var editVM: EditViewModel
    
    var body: some View {
        VStack {
            EditSlider(
                type: .grainAlpha,
                value: editVM.filter.param.grainAlpha,
                onChanged: grainAlphaSliderOnChanged,
                onEnded: grainAlphaSliderOnEnded
            )
            
            EditSlider(
                type: .grainScale,
                value: editVM.filter.param.grainScale,
                onChanged: grainScaleSliderOnChanged,
                onEnded: grainScaleSliderOnEnded
            )
        }
    }
    
    private func grainAlphaSliderOnChanged(_ value: Double) {
        editVM.send(.grainAlphaChanged(value))
    }
    
    private func grainAlphaSliderOnEnded(_ value: Double) {
        editVM.send(.grainAlphaEnded(value))
    }
    
    private func grainScaleSliderOnChanged(_ value: Double) {
        editVM.send(.grainScaleChanged(value))
    }
    
    private func grainScaleSliderOnEnded(_ value: Double) {
        editVM.send(.grainScaleEnded(value))
    }
}
