import SwiftUI

@main
struct appApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @State var routes: [Route] = []
    
    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $routes) {
                UploadView(uploadVM: .init(initialState: .init()))
                    .navigationDestination(for: Route.self) { route in
                        route.destination
                    }
            }
            .environment(\.navigate, NavigateAction(action: { route in
                routes.append(route)
            }))
        }
    }
}
