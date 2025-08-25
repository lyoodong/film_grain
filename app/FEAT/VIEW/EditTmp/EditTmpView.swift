import SwiftUI
import Photos
import PhotosUI

struct EditTmpView: View {
    @ObservedObject var editVM: EditTmpViewModel
    
    var body: some View {
        VStack {
            Text(editVM.selectedId)
            
            if editVM.isLoad {
                ProgressView()
            }
            
            if let uiImage = editVM.displayImage {
                Image(uiImage: uiImage)
            }
        }
        .onAppear { editVM.send(.onAppear(UIScreen.maxScale)) }
    }
}
