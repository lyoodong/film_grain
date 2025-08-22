import SwiftUI
import Photos
import PhotosUI

struct UploadView: View {
    @Environment(\.navigate) var navigate
    @State private var activeScreen: ActiveScreen? = nil
    @State private var activeAlert: ActiveAlert? = nil
    
    var body: some View {
        VStack {
            UploadButton(title: "업로드", action: checkPHAuthorizationStatus)
        }
        .fullScreenCover(item: $activeScreen) { screen in
            screen.view({navigate(.edit(id: $0))})
        }
        .alert(item: $activeAlert) { alert in
            alert.view
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
    
    enum ActiveAlert: String, Identifiable {
        case requestAuthorizationAlert
        
        var id: String {
            return self.rawValue
        }
        
        var view: Alert {
            switch self {
            case .requestAuthorizationAlert:
                Alert(
                    title: Text("사진 접근 권한"),
                    message: Text("사진을 업로드하려면 사진 라이브러리 접근 권한이 필요합니다."),
                    dismissButton: .default(Text("이동"))
                )
            }
        }
    }
}

//MARK: - Helpers
extension UploadView {
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
