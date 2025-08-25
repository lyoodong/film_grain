import SwiftUI
import Photos
import PhotosUI

struct EditTmpView: View {
    @ObservedObject var editVM: EditTmpViewModel
    
    var body: some View {
        VStack {
            if editVM.isLoad {
                ProgressView()
            } else {
                if let uiImage = editVM.displayImage {
                    EditZoomableImage(uiImage: uiImage)
                    Spacer()
                    EditTool(editVM: editVM)
                }
            }
        }
        .onAppear {
            editVM.send(.onAppear)
        }
    }
}

