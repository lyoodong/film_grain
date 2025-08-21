import SwiftUI

struct EditAiButton: View {
    @ObservedObject var editVM: EditViewModel

    var body: some View {
        Button("AI 추천") { editVM.send(.aiButtonTapped) }
    }
}
