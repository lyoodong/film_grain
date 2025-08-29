import SwiftUI
import Photos
import PhotosUI

struct EditTmpView: View {
    @ObservedObject var editVM: EditTmpViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            if let uiImage = editVM.displayImage {
                EditNavigation(editVM: editVM)
                
                Spacer()
                
                EditZoomableImage(uiImage: uiImage)
                
                Spacer()
                
                EditTmpAIButton(editVM: editVM)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.bg)
        .onAppear {
            editVM.send(.onAppear)
        }
    }
}
