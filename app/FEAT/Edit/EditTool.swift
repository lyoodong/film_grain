import SwiftUI

enum ToolType: String, Hashable, CaseIterable {
    case grain
    case tone
    case adjust
    case ai
    case none
    
    var systemName: String {
        switch self {
        case .grain:
            return "circle.bottomrighthalf.pattern.checkered"
        case .tone:
            return "camera.filters"
        case .adjust:
            return "dial.medium"
        case .ai:
            return "sparkles"
        case .none:
            return ""
        }
    }
    
    var title: String {
        rawValue.capitalized
    }
}

struct ToolCircleButtonStack: View {
    @ObservedObject var editVM: EditViewModel
    
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
        ToolCircleButton(type: .tone, selected: editVM.selectedTap) {
            editVM.send(.tapSelected(.tone))
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
        ToolCircleButton(type: .ai, selected: editVM.selectedTap) {
            editVM.send(.tapSelected(.ai))
            editVM.send(.aiButtonTapped)
        }
    }
}

struct ToolTap: View {
    @ObservedObject var editVM: EditViewModel
    
    var body: some View {
        VStack {
            switch editVM.selectedTap {
            case .grain:
                EditGrain(editVM: editVM)
            case .tone:
                EditColorTmp(editVM: editVM)
            case .adjust:
                EditAdjust(editVM: editVM)
            default:
                EmptyView()
            }
        }
    }
}


struct ToolCircleButton: View {
    let type: ToolType
    let selected: ToolType
    let textFont = Poppin.regular.font(size: 10)
    let iconFont = Poppin.regular.font(size: 16)
    let diameter: CGFloat = 40
    let action: () -> Void
    
    var body: some View {
        VStack(spacing: 6) {
            button
            title
        }
    }
    
    private var button: some View {
        Button(action: action, label: label)
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
            .font(textFont)
    }
    
    private var backgroundCircle: some View {
        Circle().fill(Color(.systemGray5))
    }
    
    private var image: some View {
        Image(systemName: type.systemName)
            .font(iconFont)
            .foregroundColor(.white)
    }
    
    private var stroke: some View {
        Circle()
            .stroke(selected == type ? Color.pointRed : .clear, lineWidth: 2)
    }
}
