import SwiftUI

struct EditAdjustTap: View {
    @ObservedObject var editVM: EditViewModel
    
    var body: some View {
        VStack {
            EditSlider(
                type: .contrast,
                value: editVM.filter.param.contrast,
                onChanged: contrastSliderOnChanged,
                onEnded: contrastSliderOnEnded
            )
            
            EditSlider(
                type: .temperture,
                value: editVM.filter.param.temperture,
                onChanged: tempertureSliderOnChanged,
                onEnded: tempertureSliderOnEnded
            )
        }
    }
    
    private func contrastSliderOnChanged(_ value: Double) {
        editVM.send(.contrastChanged(value))
    }
    
    private func contrastSliderOnEnded(_ value: Double) {
        editVM.send(.contrastEnded(value))
    }
    
    private func tempertureSliderOnChanged(_ value: Double) {
        editVM.send(.tempertureChanged(value))
    }
    
    private func tempertureSliderOnEnded(_ value: Double) {
        editVM.send(.tempertureEnded(value))
    }
}
