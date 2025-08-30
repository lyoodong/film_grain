import SwiftUI
import Photos
import PhotosUI

struct EditTmpView: View {
    @ObservedObject var editVM: EditTmpViewModel
    
    var body: some View {
        VStack {
            EditNavigation(editVM: editVM)
            
            ZStack(alignment: .bottomTrailing) {
                EditZoomableImage(editVM: editVM)
                EditTmpAIButton(editVM: editVM)
                    .padding(16)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.mainBackground)
        .onAppear {
            editVM.send(.onAppear)
        }
    }
}
