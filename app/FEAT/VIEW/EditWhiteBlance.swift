import SwiftUI

struct EditTemperature: View {
    @ObservedObject var editVM: EditViewModel

    var body: some View {
        EditSlider(
            name: "temperature",
            value: editVM.temperature,
            range: 2000...10000,
            step: 100
        ) { editVM.send(.temperatureChanged($0))}
    }
}
