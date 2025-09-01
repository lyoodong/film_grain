import Foundation

class Toast {
    var text: String = ""
    var isPresent: Bool = false
    
    func show(_ text: String) {
        self.text = text
        isPresent = true
    }
    
    func clear() {
        isPresent = false
        
        Task { [weak self] in
            try? await Task.sleep(for: .seconds(1))
            self?.text = ""
        }
    }
}
