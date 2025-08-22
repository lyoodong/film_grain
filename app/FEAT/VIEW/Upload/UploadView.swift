import SwiftUI

struct UploadView: View {
    @ObservedObject var uploadVM: UploadViewModel
    @Environment(\.navigate) var navigate
    
    var body: some View {
        VStack {
            UploadButton(title: "업로드") {
                uploadVM.send(.uploadButtonTapped)
            }
        }
        .fullScreenCover(isPresented: isPresentPicker) {
            UploadPhotoPickerView { id in
                uploadVM.send(.dismissPicker)
                if let id = id {
                    navigate(.edit(id: id))
                }
            } onCancel: {
                uploadVM.send(.dismissPicker)
            }
            .ignoresSafeArea()
        }
        .alert("사진 접근 권한", isPresented: isPresentAuthAlert) {
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

extension UploadView {
    fileprivate var isPresentPicker: Binding<Bool> {
        Binding(
            get: { uploadVM.state.activeScreen == .picker },
            set: { show in
                if !show { uploadVM.send(.dismissPicker) }
            }
        )
    }
    
    fileprivate var isPresentAuthAlert: Binding<Bool> {
        Binding(
            get: { uploadVM.state.activeScreen == .requestAuthorizationAlert },
            set: { show in
                if !show { uploadVM.send(.dismissPicker) }
            }
        )
    }
}
