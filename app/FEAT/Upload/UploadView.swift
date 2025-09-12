import SwiftUI

struct UploadView: View {
    @ObservedObject var uploadVM: UploadViewModel
    
    var body: some View {
        ZStack {
            navigation
            title
            status
        }
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.mainBlack)
        .photoPermissionAlert(uploadVM: uploadVM)
        .PhotoPickerFullScreen(uploadVM: uploadVM)
        .EditFullScreen(uploadVM: uploadVM)
        .infoFullScreen(uploadVM: uploadVM)
    }
    
    private var navigation: some View {
        UploadNavigation(uploadVM: uploadVM)
    }
    
    private var title: some View {
        VStack {
            UploadTitle(uploadVM: uploadVM)
            Spacer()
        }
    }
    
    private var status: some View {
        VStack {
            Spacer()
            UploadStatus(uploadVM: uploadVM)
            Spacer()
        }
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
    
    func infoFullScreen(uploadVM: UploadViewModel) -> some View {
        modifier(InfoModifier(uploadVM: uploadVM))
    }
}

fileprivate struct EditModifier: ViewModifier {
    @ObservedObject var uploadVM: UploadViewModel
    
    func body(content: Content) -> some View {
        content.fullScreenCover(
            isPresented: Binding(
                get: { uploadVM.activeScreen == .edit },
                set: { if !$0 { uploadVM.send(.dismiss)} }
            )
        ) {
            if let data = uploadVM.fetchedData,
               let image = uploadVM.fetchedImage {
                EditView(editVM: .init(initialState: .init(imageAsset: .init(originData: data, downsampledImage: image))))
            }
        }
    }
}

fileprivate struct PhotoPickerModifier: ViewModifier {
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
            .ignoresSafeArea()
        }
    }
}

fileprivate struct PhotoPermissionAlertModifier: ViewModifier {
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

fileprivate struct InfoModifier: ViewModifier {
    @ObservedObject var uploadVM: UploadViewModel
    
    func body(content: Content) -> some View {
        content.fullScreenCover(
            isPresented: Binding(
                get: { uploadVM.activeScreen == .info },
                set: { if !$0 { uploadVM.send(.dismiss)} }
            )
        ) {
            InfoView(infoVM: .init(initialState: .init()))
        }
    }
}
