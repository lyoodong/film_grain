import SwiftUI

struct EditGrain: View {
    @ObservedObject var editVM: EditViewModel

    var body: some View {
        VStack {
            grainAlphaSider
            grainScaleSider
        }
    }
    
    private var grainAlphaSider: some View {
        EditSlider(
            name: "GrainAlpha",
            value: editVM.grainAlpha,
            range: 0...1,
            step: 0.01
        ) { editVM.send(.grainAlphaChanged($0))}
    }
    
    private var grainScaleSider: some View {
        EditSlider(
            name: "GrainScale",
            value: editVM.grainScale,
            range: 1...10,
            step: 0.1
        ) { editVM.send(.grainScaleChanged($0))}
    }
}
