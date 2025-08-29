import SwiftUI

struct UploadTitle: View {
    @ObservedObject var uploadVM: UploadViewModel
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 0) {
                Text(uploadVM.loadingStatus != .none ? "" : "Select Your")
                    .font(Poppin.bold.font(size: 36))
                    .foregroundStyle(Color.mainGray)
                
                
                Text(uploadVM.loadingStatus != .none ? "" : "Photo")
                    .font(Poppin.bold.font(size: 40))
                    .foregroundStyle(Color.mainBlack)
            }
            
            Spacer()
        }
        .padding(.top, uploadVM.loadingStatus != .none ? 0 : 100)
        .animation(.easeInOut, value: uploadVM.loadingStatus)
    }
}
