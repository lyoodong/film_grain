import SwiftUI

protocol ViewModelType {
    associatedtype Action
    associatedtype State
}

typealias toVM<T: ViewModelType> = ViewModel<T.State, T.Action>

@dynamicMemberLookup
class ViewModel<S, A>: ObservableObject {
    @Published private(set) var state: S

    init(initialState: S) {
        self.state = initialState
    }

    subscript<T>(dynamicMember keyPath: KeyPath<S, T>) -> T {
        state[keyPath: keyPath]
    }

    func send(_ action: A) {
        reduce(state: &state, action: action)
    }

    func reduce(state: inout S, action: A) {
        fatalError("Must override reduce(state:action:)")
    }
}
