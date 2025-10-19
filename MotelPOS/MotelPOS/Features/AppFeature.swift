import Foundation
import SwiftUI
import ComposableArchitecture

struct AppFeature: Reducer {
    struct State: Equatable {
        var navigation = SidebarFeature.State()
        var dashboard = DashboardFeature.State()
        var rooms = RoomsFeature.State()
        var reports = ReportsFeature.State()
        var settings = SettingsFeature.State()
        var housekeeping = HousekeepingFeature.State()
        var search = SearchFeature.State()
        var aiAssistant = AIAssistantFeature.State()
        var offline = OfflineFeature.State()
        var selectedSection: SidebarSection = .dashboard
        var floatingChatPresented = false
    }

    enum Action: Equatable {
        case navigation(SidebarFeature.Action)
        case dashboard(DashboardFeature.Action)
        case rooms(RoomsFeature.Action)
        case reports(ReportsFeature.Action)
        case settings(SettingsFeature.Action)
        case housekeeping(HousekeepingFeature.Action)
        case search(SearchFeature.Action)
        case aiAssistant(AIAssistantFeature.Action)
        case offline(OfflineFeature.Action)
        case selectSection(SidebarSection)
        case toggleChat(Bool)
    }

    @Dependency(\.services) var services
    @Dependency(\.date) var date

    var body: some Reducer<State, Action> {
        Scope(state: \._dashboard, action: /Action.dashboard) {
            DashboardFeature()
        }
        Scope(state: \._rooms, action: /Action.rooms) {
            RoomsFeature()
        }
        Scope(state: \._reports, action: /Action.reports) {
            ReportsFeature()
        }
        Scope(state: \._settings, action: /Action.settings) {
            SettingsFeature()
        }
        Scope(state: \._housekeeping, action: /Action.housekeeping) {
            HousekeepingFeature()
        }
        Scope(state: \._search, action: /Action.search) {
            SearchFeature()
        }
        Scope(state: \._aiAssistant, action: /Action.aiAssistant) {
            AIAssistantFeature()
        }
        Scope(state: \._offline, action: /Action.offline) {
            OfflineFeature()
        }
        Reduce { state, action in
            switch action {
            case let .selectSection(section):
                state.selectedSection = section
                return .none
            case let .toggleChat(show):
                state.floatingChatPresented = show
                return .send(.aiAssistant(.setPresentation(show)))
            case .navigation(let navAction):
                switch navAction {
                case let .select(section):
                    state.selectedSection = section
                case .showSearch:
                    state.selectedSection = .search
                }
                return .none
            case .dashboard, .rooms, .reports, .settings, .housekeeping, .search, .aiAssistant, .offline:
                return .none
            }
        }
    }
}

extension AppFeature.State {
    var _dashboard: DashboardFeature.State {
        get { dashboard }
        set { dashboard = newValue }
    }
    var _rooms: RoomsFeature.State {
        get { rooms }
        set { rooms = newValue }
    }
    var _reports: ReportsFeature.State {
        get { reports }
        set { reports = newValue }
    }
    var _settings: SettingsFeature.State {
        get { settings }
        set { settings = newValue }
    }
    var _housekeeping: HousekeepingFeature.State {
        get { housekeeping }
        set { housekeeping = newValue }
    }
    var _search: SearchFeature.State {
        get { search }
        set { search = newValue }
    }
    var _aiAssistant: AIAssistantFeature.State {
        get { aiAssistant }
        set { aiAssistant = newValue }
    }
    var _offline: OfflineFeature.State {
        get { offline }
        set { offline = newValue }
    }
}

enum SidebarSection: String, CaseIterable, Identifiable, Equatable {
    case dashboard
    case rooms
    case reports
    case settings
    case housekeeping
    case search

    var id: String { rawValue }
    var icon: String {
        switch self {
        case .dashboard: return "chart.bar"
        case .rooms: return "bed.double"
        case .reports: return "doc.richtext"
        case .settings: return "gear"
        case .housekeeping: return "broom"
        case .search: return "magnifyingglass"
        }
    }

    var title: String {
        switch self {
        case .dashboard: return "Dashboard"
        case .rooms: return "Rooms"
        case .reports: return "Reports"
        case .settings: return "Settings"
        case .housekeeping: return "Housekeeping"
        case .search: return "Search"
        }
    }
}
