import Foundation
import ComposableArchitecture

struct SidebarFeature: Reducer {
    struct State: Equatable {
        var sections: [SidebarSection] = [.dashboard, .rooms, .reports, .settings, .housekeeping, .search]
        var selected: SidebarSection = .dashboard
    }

    enum Action: Equatable {
        case select(SidebarSection)
        case showSearch
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case let .select(section):
                state.selected = section
                return .none
            case .showSearch:
                state.selected = .search
                return .none
            }
        }
    }
}
