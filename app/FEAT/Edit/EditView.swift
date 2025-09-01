import SwiftUI
import Photos
import PhotosUI

struct EditView: View {
    @ObservedObject var editVM: EditViewModel
    
    var body: some View {
        VStack {
            EditNavigation(editVM: editVM)
            EditZoomableImage(editVM: editVM)
            EditToolTap(editVM: editVM)
            EditToolButton(editVM: editVM)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.mainBlack)
        .onAppear { editVM.send(.onAppear) }
    }
}
