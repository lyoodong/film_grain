import SwiftUI

struct EditAdjust: View {
    @ObservedObject var editVM: EditViewModel
    
    var body: some View {
        VStack {
            EditSlider(type: .contrast, value: editVM.filter.contrast) {
                editVM.send(.contrastChanged($0))
            }
            
            EditSlider(type: .temperture, value: editVM.filter.temperture) {
                editVM.send(.tempertureChanged($0))
            }
        }
    }
}
