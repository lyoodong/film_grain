import SwiftUI

struct NavigateAction {
    typealias Action = (Route) -> ()
    let action: Action
    
    func callAsFunction(_ route: Route) {
        action(route)
    }
}

extension EnvironmentValues {
    @Entry var navigate = NavigateAction { _ in }
}

enum Route: Hashable {
    case edit(id: String)
    
    @ViewBuilder
    var destination: some View {
        switch self {
            
        case let .edit(id):
            EditTmpView(editVM: EditTmpViewModel(initialState: .init(selectedId: id)))
        }
    }
}
