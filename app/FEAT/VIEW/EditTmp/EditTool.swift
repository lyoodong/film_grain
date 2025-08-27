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
        rawValue.capitalized
    }
    
    var index: Int {
        return Self.allCases.firstIndex(of: self)!
    }
    
    var maxViewHeight: CGFloat {
        switch self {
        case .grain: 400
        case .color: 300
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


struct ToolButtonStack: View {
    @ObservedObject var editVM: EditTmpViewModel
    
    var body: some View {
        HStack(alignment: .center) {
            ToolButton(type: .grain, editVM: editVM)
            ToolButton(type: .color, editVM: editVM)
            ToolButton(type: .adjust, editVM: editVM)
        }
        .background(.thinMaterial.opacity(editVM.tapOpacity))
        .highPriorityGesture(dragGesture)
    }
    
    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 10)
            .onChanged{ editVM.send(.dragToolOnChanged($0.translation.height)) }
            .onEnded { value in
                withAnimation(.interactiveSpring(
                    response: 0.2,
                    dampingFraction: 0.7,
                    blendDuration: 0.3
                )) {
                    editVM.send(.dragToolOnEnded(value.translation.height))
                }
            }
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
                    .fontWeight(.semibold)
                Spacer()
            }
        }
        .frame(height: 60)
        .foregroundColor(editVM.state.toolButtonTextColor(type))
    }
}

struct ToolTap: View {
    @ObservedObject var editVM: EditTmpViewModel
    
    var body: some View {
        if let tap = editVM.selectedTap {
            switch tap {
            case .grain:
                EditTmpGrain(editVM: editVM)
            case .color:
                EditColor(editVM: editVM)
            case .adjust:
                EditAdjust(editVM: editVM)
            }
        }
    }
}
