import SwiftUI

@main
struct appApp: App {
    var body: some Scene {
        WindowGroup {
            EditView(editVM: .init(initialState: .init()))
        }
    }
}
