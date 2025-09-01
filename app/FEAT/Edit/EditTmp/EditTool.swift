import SwiftUI

enum ToolType: String, Hashable, CaseIterable {
    case grain
    case color
    case adjust
    case none
    
    var systemName: String {
        switch self {
        case .grain:
            return "circle.grid.3x3.fill"
        case .color:
            return "paintpalette"
        case .adjust:
            return "slider.horizontal.3"
        case .none:
            return ""
        }
    }
    
    var title: String {
        rawValue.uppercased()
    }
}

//MARK: - REFACTOR
struct ToolCircleButtonStack: View {
    @ObservedObject var editVM: EditTmpViewModel
    
    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            grainButton
            colorButton
            adjustButton
            divider
            aiButton
        }
        .padding(.horizontal, 12)
        .padding(.bottom, 16)
    }
    
    private var grainButton: some View {
        ToolCircleButton(type: .grain, selected: editVM.selectedTap) {
            editVM.send(.tapSelected(.grain))
        }
    }
    
    private var colorButton: some View {
        ToolCircleButton(type: .color, selected: editVM.selectedTap) {
            editVM.send(.tapSelected(.color))
        }
    }
    
    private var adjustButton: some View {
        ToolCircleButton(type: .adjust, selected: editVM.selectedTap) {
            editVM.send(.tapSelected(.adjust))
        }
    }
    
    private var divider: some View {
        Rectangle()
            .fill(Color.white.opacity(0.25))
            .frame(width: 1, height: 28)
            .padding(.horizontal, 2)
    }
    
    private var aiButton: some View {
        ToolCircleButton(type: .grain, selected: .grain) {
            editVM.send(.tapSelected(.grain))
        }
    }
}

struct ToolCircleButton: View {
    let type: ToolType
    let selected: ToolType
    let action: () -> Void
    
    private let diameter: CGFloat = 44
    
    var body: some View {
        VStack(spacing: 6) {
            Button(action: action, label: label)
            title
        }
    }
    
    private func label() -> some View {
        ZStack {
            backgroundCircle
            image
        }
        .frame(width: diameter, height: diameter)
        .overlay(stroke)
    }
    
    private var title: some View {
        Text(type.title)
            .font(.caption2)
            .foregroundColor(.white.opacity(0.9))
    }
    
    private var backgroundCircle: some View {
        Circle().fill(Color(.systemGray5))
    }
    
    private var image: some View {
        Image(systemName: type.systemName)
            .font(.system(size: 18, weight: .semibold))
            .foregroundColor(.white)
    }
    
    private var stroke: some View {
        Circle()
            .stroke(selected == type ? Color.blue : .clear, lineWidth: 2)
    }
}
