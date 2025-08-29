import SwiftUI

struct UploadView: View {
    @ObservedObject var uploadVM: UploadViewModel
    
    var body: some View {
        ZStack {
            uploadScreenContent
        }
    }
    
    private var uploadScreenContent: some View {
        ZStack {
            VStack {
                UploadTitle(uploadVM: uploadVM)
                Spacer()
            }
            
            VStack {
                Spacer()
                UploadStatus(uploadVM: uploadVM)
                Spacer()
            }
        }
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.mainBackground)
        .photoPermissionAlert(uploadVM: uploadVM)
        .PhotoPickerFullScreen(uploadVM: uploadVM)
        .EditFullScreen(uploadVM: uploadVM)
    }
}

extension View {
    func photoPermissionAlert(uploadVM: UploadViewModel) -> some View {
        modifier(PhotoPermissionAlertModifier(uploadVM: uploadVM))
    }
    
    func PhotoPickerFullScreen(uploadVM: UploadViewModel) -> some View {
        modifier(PhotoPickerModifier(uploadVM: uploadVM))
    }
    
    func EditFullScreen(uploadVM: UploadViewModel) -> some View {
        modifier(EditModifier(uploadVM: uploadVM))
    }
}

struct EditModifier: ViewModifier {
    @ObservedObject var uploadVM: UploadViewModel
    
    func body(content: Content) -> some View {
        content.fullScreenCover(
            isPresented: Binding(
                get: { uploadVM.activeScreen == .edit },
                set: { if !$0 { uploadVM.send(.dismiss)} }
            )
        ) {
            if let image = uploadVM.originImage {
                EditTmpView(editVM: .init(initialState: .init(image: image)))
            }
        }
    }
}

struct PhotoPickerModifier: ViewModifier {
    @ObservedObject var uploadVM: UploadViewModel
    
    func body(content: Content) -> some View {
        content.fullScreenCover(
            isPresented: Binding(
                get: { uploadVM.activeScreen == .picker },
                set: { if !$0 { uploadVM.send(.dismiss)} }
            )
        ) {
            UploadPicker { id in
                uploadVM.send(.onPicked(id))
            }
        }
    }
}

struct PhotoPermissionAlertModifier: ViewModifier {
    @ObservedObject var uploadVM: UploadViewModel
    
    func body(content: Content) -> some View {
        content.alert(
            "need access to the gallery",
            isPresented: Binding(
                get: { uploadVM.activeScreen == .requestAuthorizationAlert },
                set: { if !$0 { uploadVM.send(.dismiss) } }
            ),
            actions: {
                Button(action: openAppSettings) {
                    Text("Move")
                        .foregroundColor(.white)
                }
            },
            message: {
                Text("please allow access in Settings.")
            }
        )
    }
    
    private func openAppSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}
