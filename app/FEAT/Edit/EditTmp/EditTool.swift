import SwiftUI

enum ToolType: String, Hashable, CaseIterable {
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
        rawValue.uppercased()
    }
    
    var index: Int {
        return Self.allCases.firstIndex(of: self)!
    }
    
    var maxViewHeight: CGFloat {
        switch self {
        case .grain: 200
        case .color: 200
        case .adjust: 200
            
        }
    }
}

struct EditTool: View {
    @ObservedObject var editVM: EditTmpViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            ToolButtonStack(editVM: editVM)
            ToolTap(editVM: editVM)
        }
        .frame(height: editVM.toolHeight)
    }
}


struct ToolButton: View {
    let type: ToolType
    @ObservedObject var editVM: EditTmpViewModel
    
    var body: some View {
        Button {
            withAnimation(.interactiveSpring(
                response: 0.2,
                dampingFraction: 0.7,
                blendDuration: 0.3
            )) {
                editVM.send(.tapSelected(type))
            }
        } label: {
            HStack {
                Spacer()
                Text(type.title)
                    .font(Poppin.semiBold.font(size: 16))
                Spacer()
            }
        }
        .frame(height: 24)
        .foregroundColor(editVM.state.toolButtonTextColor(type))
    }
}
