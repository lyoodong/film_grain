import SwiftUI

@main
struct appApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            UploadView(uploadVM: .init(initialState: .init()))
        }
    }
}
