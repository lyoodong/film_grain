import SwiftUI

struct UploadTitle: View {
    @ObservedObject var uploadVM: UploadViewModel
    @Namespace var namespace
    
    var body: some View {
        HStack {
            if uploadVM.loadingStatus != .none {
                Spacer()
            }
            
            Text(uploadVM.loadingStatus != .none ? "" : "Select Your\nPhoto")
                .font(uploadVM.loadingStatus != .none ? Poppin.medium.font(size: 16) : Poppin.semiBold.font(size: 36))
            Spacer()
        }
        .padding(.bottom, uploadVM.loadingStatus != .none ? 44 : 0)
        .padding(.top, uploadVM.loadingStatus != .none ? 0 : 100)
        .animation(.spring, value: uploadVM.loadingStatus)
    }
}
