
import SwiftUI

extension View {
    func fullScreenCover(
        isPresented: Bool,
        @ViewBuilder content: @escaping () -> some View
    ) -> some View {
        self.fullScreenCover(
            isPresented: Binding(
                get: { isPresented },
                set: { _ in }
            ),
            content: content
        )
    }
    
    func alert(
        _ title: String,
        isPresented: Bool,
        @ViewBuilder actions: @escaping () -> some View,
        @ViewBuilder message: @escaping () -> some View
    ) -> some View {
        self.alert(
            title,
            isPresented: Binding(
                get: { isPresented },
                set: { _ in }
            ),
            actions: actions,
            message: message
        )
    }
}
