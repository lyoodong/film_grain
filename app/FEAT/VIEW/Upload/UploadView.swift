import SwiftUI

struct UploadView: View {
    @ObservedObject var uploadVM: UploadViewModel
//    private let uploadPhotoPicker = UploadPhotoPicker()
    
    var body: some View {
        VStack {
            UploadButton(title: "업로드") {
                uploadVM.send(.uploadButtonTapped)
            }
        }
        .fullScreenCover(
            isPresented: uploadVM.activeScreen == .picker,
            content: {
            UploadPhotoPickerView { id in
                uploadVM.send(.photoSelected(id))
                uploadVM.send(.dismissPicker)
            } onCancel: {
                uploadVM.send(.dismissPicker)
                uploadVM.send(.dismissPicker)
            }
            .ignoresSafeArea()
        })

        .alert("사진 접근 권한", isPresented: uploadVM.activeScreen == .requestAuthorizationAlert) {
            Button("설정으로 이동") {
                if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsURL)
                }
            }
            
            Button("취소", role: .cancel) {
                uploadVM.send(.dismissPicker)
            }
        } message: {
            Text("사진을 업로드하려면 사진 라이브러리 접근 권한이 필요합니다.")
        }
    }
}
