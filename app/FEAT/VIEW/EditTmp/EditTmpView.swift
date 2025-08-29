import SwiftUI
import Photos
import PhotosUI

struct EditTmpView: View {
    @ObservedObject var editVM: EditTmpViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            if editVM.isLoad {
                ProgressView()
            } else {
                if let uiImage = editVM.displayImage {
                    EditTmpSaveButton(editVM: editVM)
                    EditZoomableImage(uiImage: uiImage)
                    EditTool(editVM: editVM)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.bg)
        .onAppear {
            editVM.send(.onAppear)
        }
    }
}

