import SwiftUI

struct EditTmpGrain: View {
    @ObservedObject var editVM: EditTmpViewModel
    
    var body: some View {
        VStack {
            EditTmpSlider(type: .grainAlpha, value: editVM.filter.grainAlpha) {
                editVM.send(.grainAlphaChanged($0))
            }
            
            EditTmpSlider(type: .grainScale, value: editVM.filter.grainScale) {
                editVM.send(.grainScaleChanged($0))
            }
        }
    }
}
