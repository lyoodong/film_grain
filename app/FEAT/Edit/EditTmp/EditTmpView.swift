import SwiftUI
import Photos
import PhotosUI

struct EditTmpView: View {
    @ObservedObject var editVM: EditTmpViewModel
    
    var body: some View {
        VStack {
            EditNavigation(editVM: editVM)
            EditZoomableImage(editVM: editVM)
            Spacer()
            EditTmpAIButton(editVM: editVM)
            EditTool(editVM: editVM)
        }
        .animation(.bouncy, value: editVM.isFirstAI)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.mainBackground)
        .onAppear {
            editVM.send(.onAppear)
        }
    }
}
