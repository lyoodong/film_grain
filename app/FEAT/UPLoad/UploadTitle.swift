import SwiftUI

struct UploadTitle: View {
    @ObservedObject var uploadVM: UploadViewModel
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 0) {
                Text(uploadVM.loadingStatus != .none ? "" : "Select Your\nPhoto")
                    .font(Poppin.semiBold.font(size: 36))
                    .foregroundStyle(Color.mainWhite)
            }
            
            Spacer()
        }
        .padding(.top, uploadVM.loadingStatus != .none ? 0 : 100)
        .animation(.easeInOut, value: uploadVM.loadingStatus)
    }
}
