import SwiftUI
import Photos
import PhotosUI

struct EditPhotoPicker: View {
    @ObservedObject var editVM: EditViewModel
    
    var body: some View {
        PhotosPicker(
            selection: Binding<PhotosPickerItem?>(
                get: { editVM.selectedItem },
                set: { newValue in
                    guard let picked = newValue,
                          let id = picked.itemIdentifier,
                          let asset = PHAsset.fetchAssets(withLocalIdentifiers: [id], options: nil).firstObject
                    else { return }
                    
                    let opts = PHImageRequestOptions()
                    opts.isNetworkAccessAllowed = true
                    
                    PHImageManager.default().requestImageDataAndOrientation(
                        for: asset,
                        options: opts
                    ) { data, _, _, info in
                        let inCloud = (info?[PHImageResultIsInCloudKey] as? Bool) == true
                        print(inCloud
                              ? "☁️ 아직 iCloud에서 내려받는 중"
                              : "📁 로컬에 다운로드 완료")
                    }
                
                    editVM.send(.photoSelected(picked))
                }
            ),
            matching: .images,
            photoLibrary: .shared()
        ) {
            uploadLabel
        }
    }
    
    private var uploadLabel: some View {
        Label("Upload", systemImage: "photo.on.rectangle")
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            .background(Color.green.opacity(0.2))
            .cornerRadius(8)
    }
}
