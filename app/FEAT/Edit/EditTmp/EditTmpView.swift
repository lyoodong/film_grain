import SwiftUI
import Photos
import PhotosUI

struct EditTmpView: View {
    @ObservedObject var editVM: EditTmpViewModel
    
    var body: some View {
        VStack {
            EditNavigation(editVM: editVM)
            EditZoomableImage(editVM: editVM)
            TmpView(editVM: editVM)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.mainBlack)
        .onAppear {
            editVM.send(.onAppear)
        }
    }
}

struct TmpView: View {
    @ObservedObject var editVM: EditTmpViewModel
    
    var body: some View {
        VStack(alignment: .center) {
            if editVM.isSwipe {
                Tool(editVM: editVM)
            } else {
                SwipeHandler(editVM: editVM)
            }
        }
        .ignoresSafeArea()
    }
    
    private var aiButtonStack: some View {
        HStack {
            Spacer()
            EditTmpAIButton(editVM: editVM)
        }
    }
}

struct SwipeHandler: View {
    @ObservedObject var editVM: EditTmpViewModel
    
    var body: some View {
        VStack(alignment: .center, spacing: 12) {
            text
            handler
        }
        .padding(.top, 16)
        .padding(.bottom, 60)
    }
    
    private var text: some View {
        Text("Swipe to edit")
            .font(Poppin.medium.font(size: 12))
            .foregroundStyle(Color.textGray)
    }
    
    private var handler: some View {
        RoundedRectangle(cornerRadius: 3)
            .fill(Color.mainWhite)
            .frame(width: 36, height: 6)
    }
}

struct Tool: View {
    @ObservedObject var editVM: EditTmpViewModel
    
    var body: some View {
        VStack(alignment: .center) {
            ToolButtonStack(editVM: editVM)
            ToolTap(editVM: editVM)
        }
        .background(.thinMaterial.opacity(editVM.tapOpacity))
        .animation(.smooth, value: editVM.tapOpacity)
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
        .highPriorityGesture(dragGesture)
    }
    
    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 5)
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

struct ToolTap: View {
    @ObservedObject var editVM: EditTmpViewModel
    
    var body: some View {
        if let tap = editVM.selectedTap {
            switch tap {
            case .grain:
                EditTmpGrain(editVM: editVM)
            case .color:
//                EditColor(editVM: editVM)
                EditTmpGrain(editVM: editVM)
            case .adjust:
                EditAdjust(editVM: editVM)
            }
        }
    }
}
