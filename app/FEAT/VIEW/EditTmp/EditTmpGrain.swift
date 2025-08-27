import SwiftUI

struct EditTmpGrain: View {
    @ObservedObject var editVM: EditTmpViewModel
    
    var body: some View {
        VStack {
            EditTmpSlider(type: .grainAlpha, value: editVM.grainAlpha) {
                editVM.send(.grainAlphaChanged($0))
            }
        }
    }
}
