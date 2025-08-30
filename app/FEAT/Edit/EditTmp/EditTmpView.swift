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
        .background(Color.mainBackground)
        .onAppear {
            editVM.send(.onAppear)
        }
    }
}

struct TmpView: View {
    @ObservedObject var editVM: EditTmpViewModel
    
    var body: some View {
        VStack(alignment: .center) {
            aiButtonStack
            Tool(editVM: editVM)
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

struct Tool: View {
    @ObservedObject var editVM: EditTmpViewModel
    
    var body: some View {
        VStack(alignment: .center) {
            ToolButtonStack(editVM: editVM)
            ToolTap(editVM: editVM)
        }
        .background(.thinMaterial.opacity(editVM.tapOpacity))
        .animation(.default, value: editVM.isEditing)
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
