import SwiftUI

struct EditTool: View {
    @ObservedObject var editVM: EditTmpViewModel
    
    var body: some View {
        HStack(alignment: .center) {
            ToolButton(type: .grain) { editVM.send(.grainButtonTapped)}
            Spacer()
            ToolButton(type: .color) { editVM.send(.colorButtonTapped) }
            Spacer()
            ToolButton(type: .adjust) { editVM.send(.adjustButtonTapped) }
        }
        .padding(.horizontal, 16)
        .background(Color.clear)
    }
}

struct ToolButton: View {
    let type: ToolButtonType
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Text(type.title)
                    .fontWeight(.semibold)
            }
        }
        .foregroundColor(.white)
    }
}

enum ToolButtonType: String {
    case grain
    case color
    case adjust
    
    var systemName: String {
        switch self {
        case .grain:
            return "circle.grid.3x3.fill"
        case .color:
            return "paintpalette"
        case .adjust:
            return "slider.horizontal.3"
        }
    }
    
    var title: String {
        rawValue.capitalized
    }
}
