import SwiftUI
import MessageUI

struct EmailFrame {
    let recipients: [String]
    let subject: String
    let body: String
}

struct InfoEmailView: UIViewControllerRepresentable {
    let frame: EmailFrame
    
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        var parent: InfoEmailView
        init(parent: InfoEmailView) { self.parent = parent }
        
        func mailComposeController(_ controller: MFMailComposeViewController,
                                   didFinishWith result: MFMailComposeResult,
                                   error: Error?) {
            
            controller.dismiss(animated: true)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let vc = MFMailComposeViewController()
        vc.setToRecipients(frame.recipients)
        vc.setSubject(frame.subject)
        vc.setMessageBody(frame.body, isHTML: false)
        vc.mailComposeDelegate = context.coordinator
        return vc
    }
    
    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}
}
