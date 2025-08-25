import SwiftUI
import Photos
import PhotosUI

struct EditTmpView: View {
    @ObservedObject var editVM: EditTmpViewModel
    
    var body: some View {
        Text(editVM.selectedId)
        .onAppear { editVM.send(.onAppear(UIScreen.maxScale)) }
    }
}
