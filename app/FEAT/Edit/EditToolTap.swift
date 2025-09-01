import SwiftUI

struct EditToolTap: View {
    @ObservedObject var editVM: EditViewModel
    
    var body: some View {
        VStack {
            switch editVM.selectedTap {
            case .grain:
                EditGrainTap(editVM: editVM)
            case .tone:
                EditToneTap(editVM: editVM)
            case .adjust:
                EditAdjustTap(editVM: editVM)
            default:
                EmptyView()
            }
        }
    }
}
