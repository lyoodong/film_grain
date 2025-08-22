import UIKit
import Photos

class AppDelegate: NSObject, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        checkPHAuthorizationStatus()
        return true
    }
    
    private func checkPHAuthorizationStatus() {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        
        if status == .notDetermined {
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { _ in }
        }
    }
}
