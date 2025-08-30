import SwiftUI
import Photos
import PhotosUI

struct EditTmpView: View {
    @ObservedObject var editVM: EditTmpViewModel
    
    var body: some View {
        VStack {
            EditNavigation(editVM: editVM)
            EditZoomableImage(editVM: editVM)
            TmpView(editVM: editVM)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.mainBackground)
        .onAppear {
            editVM.send(.onAppear)
        }
    }
}

struct TmpView: View {
    @ObservedObject var editVM: EditTmpViewModel
    
    var body: some View {
        ZStack(alignment: .center) {
            aiButtonStack
        }
    }
    
    private var aiButtonStack: some View {
        HStack {
            Spacer()
            EditTmpAIButton(editVM: editVM)
        }
    }
}
