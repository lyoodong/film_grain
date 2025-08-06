import SwiftUI

struct EditContrast: View {
    @ObservedObject var editVM: EditViewModel

    var body: some View {
        EditSlider(
            name: "Contrast",
            value: editVM.contrastValue,
            range: -100...100,
            step: 1
        ) { editVM.send(.contrastChanged($0)) }
    }
}
