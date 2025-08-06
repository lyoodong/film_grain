import SwiftUI
import Photos
import PhotosUI

struct EditView: View {
    @ObservedObject var editVM: EditViewModel
    
    var body: some View {
        editor
        photoControler
        .onAppear {
            let size = UIScreen.main.bounds.size
            let scale = UIScreen.main.scale
            let max = max(size.height, size.width)
            editVM.send(.previewWidthUpdated(max * scale))
        }
        .padding()
    }
    
    private var editor: some View {
        VStack {
            if let image = editVM.displayImage {
                EditImage(image: image)
                    .contrast(editVM.contrast)
                VStack {
                    EditAiButton(editVM: editVM)
                    EditGrain(editVM: editVM)
                    EditContrast(editVM: editVM)
                    EditColorGrading(editVM: editVM)
                }
            }
        }
    }
    
    private var photoControler: some View {
        HStack {
            EditPhotoPicker(editVM: editVM)
            EditSaveButton(editVM: editVM)
        }
    }
}
