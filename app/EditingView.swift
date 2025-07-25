import SwiftUI
import Photos
import PhotosUI

struct EditingView: View {
    
    @ObservedObject var editVM: EditingViewModel
    
    //photo picker를 위한 상태
    @State private var selectedItem: PhotosPickerItem?
    
    var body: some View {
        VStack {
            if let image = editVM.displayedImage  {
                displayedImage(image)
            }
            
            photoPicker
        }
        .padding()
    }
    
    private func displayedImage(_ image: UIImage) -> some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFit()
    }
    
    private var photoPicker: some View {
        PhotosPicker("업로드", selection: $selectedItem)
        .onChange(of: selectedItem) { _, picked in
            guard let picked else { return }
            
            picked.loadTransferable(type: Data.self) { result in
                if case let .success(data?) = result,
                   let ui = UIImage(data: data)?.fixedOrientation() {
                    DispatchQueue.main.async {
                        editVM.send(.photoSelected(ui))
                    }
                }
            }
        }
    }
}


