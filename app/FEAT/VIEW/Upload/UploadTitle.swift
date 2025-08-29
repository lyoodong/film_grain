import SwiftUI

struct UploadTitle: View {
    @ObservedObject var uploadVM: UploadViewModel
    @Namespace var namespace
    
    var body: some View {
        HStack {
            if uploadVM.loadingStatus != .none {
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 0) {
                Text(uploadVM.loadingStatus != .none ? "" : "Select Your")
                    .font(uploadVM.loadingStatus != .none ? Poppin.medium.font(size: 16) : Poppin.semiBold.font(size: 36))
                    .foregroundStyle(Color.mainGray)
                
                Text(uploadVM.loadingStatus != .none ? "" : "Photo")
                    .font(uploadVM.loadingStatus != .none ? Poppin.medium.font(size: 16) : Poppin.bold.font(size: 40))
                    .foregroundStyle(Color.mainBlack)
            }
            
            Spacer()
        }
        .padding(.bottom, uploadVM.loadingStatus != .none ? 44 : 0)
        .padding(.top, uploadVM.loadingStatus != .none ? 0 : 100)
        .animation(.spring, value: uploadVM.loadingStatus)
    }
}
