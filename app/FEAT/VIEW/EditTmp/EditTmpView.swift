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
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
            }
        }
        .onAppear {
            editVM.send(.onAppear)
        }
        .onDisappear() {
            editVM.send(.onDisappear)
        }
    }
}
