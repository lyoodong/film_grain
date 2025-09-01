import SwiftUI
import Photos
import PhotosUI

struct EditView: View {
    @ObservedObject var editVM: EditViewModel
    
    var body: some View {
        VStack {
            EditNavigation(editVM: editVM)
            EditZoomableImage(editVM: editVM)
            Spacer(minLength: 32)
            ToolTap(editVM: editVM)
            ToolCircleButtonStack(editVM: editVM)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.mainBlack)
        .onAppear {
            editVM.send(.onAppear)
        }
    }
}
