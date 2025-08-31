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
}

struct EditToolTmpView: View {
    @ObservedObject var editVM: EditTmpViewModel
    
    var body: some View {
        VStack(alignment: .center) {
            VStack {
                if let _ = editVM.selectedTap  {
                    ToolHandler()
                        .padding(.top, 12)
                        .padding(.bottom, 8)
                }
                
                ToolButtonStack(editVM: editVM)
            }
            .highPriorityGesture(dragGesture)
            
            if let _ = editVM.selectedTap  {
                ToolTap(editVM: editVM)
                    .background(background)
                    .frame(height: editVM.movingEditSheetHeight)
            }
        }
        .background(radiusBackground)
    }
    
    private var radiusBackground: some View {
        var color: Color
        
        if let _ = editVM.selectedTap { color = .sheetGray }
        else { color = .clear }
        
        return color
            .clipShape(unevenRadius)
            .ignoresSafeArea()
    }

    private var unevenRadius: some Shape {
        UnevenRoundedRectangle(topLeadingRadius: 16, topTrailingRadius: 16)
    }
    
    private var background: some View {
        GeometryReader { proxy in
            Color.clear
                .onAppear {
                    let height = proxy.size.height
                    editVM.send(.initialEditSheetHeightChnaged(height))
                }
                .onChange(of: proxy.size) { _, size in
                    editVM.send(.initialEditSheetHeightChnaged(size.height))
                }
        }
    }
    
    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 5, coordinateSpace: .global)
            .onChanged(handleDragGestureOnChnaged)
            .onEnded(handleDragGestureOnEnded)
    }
    
    private func handleDragGestureOnChnaged(_ value: DragGesture.Value) {
        editVM.send(.dragToolOnChanged(value.translation.height))
    }
    
    private func handleDragGestureOnEnded(_ value: DragGesture.Value) {
        editVM.send(.dragToolOnEnded(value.translation.height))
    }
}

struct ToolHandler: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 3)
            .fill(Color.mainWhite)
            .frame(width: 36, height: 6)
    }
}

struct ToolButtonStack: View {
    @ObservedObject var editVM: EditTmpViewModel
    
    var body: some View {
        HStack {
            ToolButton(type: .grain, editVM: editVM)
            ToolButton(type: .color, editVM: editVM)
            ToolButton(type: .adjust, editVM: editVM)
        }
    }
}

struct ToolTap: View {
    @ObservedObject var editVM: EditTmpViewModel
    
    var body: some View {
        VStack {
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
        .opacity(editVM.tapOpacity)
    }
}

struct ToolButton: View {
    let type: ToolType
    @ObservedObject var editVM: EditTmpViewModel
    
    var body: some View {
        Button {
            editVM.send(.tapSelected(type))
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
