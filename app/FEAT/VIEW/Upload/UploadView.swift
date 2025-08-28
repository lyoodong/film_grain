import SwiftUI
import Photos
import PhotosUI

struct UploadView: View {
    @Environment(\.navigate) var navigate
    @State private var activeScreen: ActiveScreen? = nil
    @State private var activeAlert: ActiveAlert? = nil
    
    var body: some View {
        VStack {
            UploadTitle()
            Spacer()
            UploadButton(title:"Upload", action: checkPHAuthorizationStatus)
        }
        .padding(.horizontal, 16)
        .fullScreenCover(item: $activeScreen) { screen in
            screen.view({navigate(.edit(id: $0))})
        }
        .photoPermissionAlert(activeAlert: $activeAlert)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.bg)
    }
    
    private func checkPHAuthorizationStatus() {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        switch status {
        case .denied:
            activeAlert = .requestAuthorizationAlert
        case .authorized, .limited:
            activeScreen = .picker
        default:
            fatalError()
        }
    }
}

//MARK: - 얼럿, 피커 상태
extension UploadView {
    enum ActiveScreen: String, Identifiable {
        case picker
        
        var id: String {
            return self.rawValue
        }
        
        @ViewBuilder
        func view(_ uploadCompletionHandler: @escaping (String) -> Void) -> some View {
            switch self {
            case .picker:
                UploadPhotoPickerView { id in
                    if let id {
                        uploadCompletionHandler(id)
                    }
                }
                .ignoresSafeArea()
            }
        }
    }
    
    enum ActiveAlert: String {
        case requestAuthorizationAlert
    }
}

extension View {
    func photoPermissionAlert(
        activeAlert: Binding<UploadView.ActiveAlert?>
    ) -> some View {
        modifier(PhotoPermissionAlertModifier(activeAlert: activeAlert))
    }
}

struct PhotoPermissionAlertModifier: ViewModifier {
    @Binding var activeAlert: UploadView.ActiveAlert?
    
    func body(content: Content) -> some View {
        content.alert(
            "need access to the gallery",
            isPresented: Binding(
                get: { activeAlert == .requestAuthorizationAlert },
                set: { if !$0 { activeAlert = nil } }
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
