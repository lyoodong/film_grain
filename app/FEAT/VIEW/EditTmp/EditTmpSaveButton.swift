import SwiftUI

struct EditTmpSaveButton: View {
    let editVM: EditTmpViewModel
    
    var body: some View {
        HStack() {
            Spacer()
            
            Button {
                editVM.send(.saveButtonTapped)
            } label: {
                Image(systemName: "square.and.arrow.up.circle")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30) 
            }
        }
    }
}
