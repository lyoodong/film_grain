import SwiftUI

struct EditAdjust: View {
    @ObservedObject var editVM: EditTmpViewModel
    
    var body: some View {
        VStack {
            EditTmpSlider(type: .contrast, value: editVM.filter.contrast) {
                editVM.send(.contrastChanged($0))
            }
            
            EditTmpSlider(type: .temperture, value: editVM.filter.temperture) {
                editVM.send(.tempertureChanged($0))
            }
        }
    }
}
