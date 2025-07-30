import SwiftUI
import Photos
import PhotosUI

struct EditingView: View {
    
    @ObservedObject var editVM: EditingViewModel
    
    //photo picker를 위한 상태
    @State private var selectedItem: PhotosPickerItem?
    @State private var grainAlpha: Float = 0
    
    var body: some View {
        VStack {
            if let image = editVM.displayedImage  {
                displayedImage(image)
                grainSlider
            }
            
            HStack {
                photoPicker
                saveButton
            }
        }
        .padding()
    }
    
    private func displayedImage(_ image: UIImage) -> some View {
        Image(uiImage: image)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(maxWidth: .infinity)
    }
    
    private var grainSlider: some View {
        HStack {
            Text("Grain: \(Int(grainAlpha * 100))%")
            Slider(value: $grainAlpha)
                .onChange(of: grainAlpha) { _, value in
                    editVM.send(.grainSliderChanged(value))
                }
        }
    }
    
    private var photoPicker: some View {
        PhotosPicker(
            selection: $selectedItem,
            matching: .images,
            photoLibrary: .shared()
        ){ uploadLabel }
            .onChange(of: selectedItem) { _, picked in
                guard let picked else { return }
                editVM.send(.photoSelected(picked))
            }
    }
    
    
    private var uploadLabel: some View {
        Label("Upload", systemImage: "photo.on.rectangle")
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            .background(Color.green.opacity(0.2))
            .cornerRadius(8)
    }
    
    private var saveButton: some View {
        Button {
            editVM.send(.saveButtonTapped)
        } label: {
            saveLabel
        }
    }
    
    private var saveLabel: some View {
        Label("Save", systemImage: "square.and.arrow.down")
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            .background(Color.blue.opacity(0.2))
            .cornerRadius(8)
    }
}
