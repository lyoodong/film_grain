import SwiftUI

struct EditGrainTap: View {
    @ObservedObject var editVM: EditViewModel
    
    var body: some View {
        VStack {
            EditSlider(type: .grainAlpha, value: editVM.filter.grainAlpha) {
                editVM.send(.grainAlphaChanged($0))
            }
            
            EditSlider(type: .grainScale, value: editVM.filter.grainScale) {
                editVM.send(.grainScaleChanged($0))
            }
        }
    }
}
