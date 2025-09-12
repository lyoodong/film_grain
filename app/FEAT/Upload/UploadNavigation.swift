import SwiftUI

struct UploadNavigation: View {
    @ObservedObject var uploadVM: UploadViewModel
    private let font = Poppin.semiBold.font(size: 20)
    private let diameter: CGFloat = 40
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button(action: infoButtonAction, label: infoButtonlabel)
            }
            
            Spacer()
        }
    }
    
    private func infoButtonAction() -> Void {
        uploadVM.send(.infoButtonTapped)
    }

    private func infoButtonlabel() -> some View {
        
        return Image(systemName: "info.circle")
            .font(font)
            .foregroundColor(.white)
            .frame(width: diameter, height: diameter)
    }
}
