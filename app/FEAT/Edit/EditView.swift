import SwiftUI

struct EditView: View {
    @ObservedObject var editVM: EditViewModel
    
    var body: some View {
        VStack {
            EditNavigation(editVM: editVM)
            EditZoomableImage(editVM: editVM)
            EditToolTap(editVM: editVM)
            EditToolButton(editVM: editVM)
            EditUndoRedoBar(editVM: editVM)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.mainBlack)
        .ignoresSafeArea(.all, edges: .bottom)
        .statusBarHidden()
        .onAppear { editVM.send(.onAppear) }
    }
}
