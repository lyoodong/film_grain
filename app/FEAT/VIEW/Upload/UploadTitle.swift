import SwiftUI

struct UploadTitle: View {
    @ObservedObject var uploadVM: UploadViewModel
    @Namespace var namespace
    
    var body: some View {
        HStack {
            if uploadVM.isLoading {
                Spacer()
            }
            
            Text(uploadVM.isLoading ? "" : "Select Your\nPhoto")
                .font(uploadVM.isLoading ? Poppin.medium.font(size: 16) : Poppin.semiBold.font(size: 36))
            Spacer()
        }
        .padding(.bottom, uploadVM.isLoading ? 44 : 0)
        .padding(.top, uploadVM.isLoading ? 0 : 100)
        .animation(.spring, value: uploadVM.isLoading)
    }
}
