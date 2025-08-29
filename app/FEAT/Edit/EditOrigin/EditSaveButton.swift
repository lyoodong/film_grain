import SwiftUI

struct EditSaveButton: View {
    @ObservedObject var editVM: EditViewModel
    
    var body: some View {
        Button {
            editVM.send(.saveButtonTapped)
        } label: {
            saveLabel
        }
    }
    
    private var saveLabel: some View {
        Label("Save", systemImage: "square.and.arrow.down")
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            .background(Color.blue.opacity(0.2))
            .cornerRadius(8)
    }
}
