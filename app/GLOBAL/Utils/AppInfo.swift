import UIKit

enum AppInfo {
    static var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    }
    
    static var appVersionText: String {
        return "Version " + AppInfo.appVersion
    }
    
    static var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
    }
    
    static var versionWithBuild: String {
        "\(appVersion) (\(buildNumber))"
    }
    
    static var osVersion: String {
        "\(UIDevice.current.systemVersion)"
    }
    
    static var emailFrame: EmailFrame {
        return .init(
            recipients: ["1008.filmgrain@gmail.com"],
            subject: "Report: ",
            body: """
            Hello,
            
            App Version: \(appVersion)
            OS Version: \(osVersion)
            """
        )
    }
}

