import Foundation
import ComposableArchitecture

struct SearchFeature: Reducer {
    struct State: Equatable {
        var query: String = ""
        var results: [SearchResult] = []
        var offlineResults: Bool = true
    }

    struct SearchResult: Identifiable, Equatable {
        var id = UUID()
        var title: String
        var subtitle: String
        var entity: String
    }

    enum Action: Equatable {
        case updateQuery(String)
        case search
        case searchResponse(Result<[SearchResult], Error>)
    }

    @Dependency(\.services) var services

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case let .updateQuery(query):
                state.query = query
                return .none
            case .search:
                guard !state.query.isEmpty else { return .none }
                return .run { [query = state.query] send in
                    let matches = try await performLocalSearch(query: query)
                    await send(.searchResponse(.success(matches)))
                }
            case let .searchResponse(.success(results)):
                state.results = results
                return .none
            case .searchResponse(.failure):
                state.results = []
                return .none
            }
        }
    }

    private func performLocalSearch(query: String) async throws -> [SearchResult] {
        let guests = ["Alex Rivers", "Jamie Chen", "Taylor Singh", "Jordan Lane"]
        return guests.filter { $0.localizedCaseInsensitiveContains(query) }.map {
            SearchResult(title: $0, subtitle: "Guest", entity: "guest")
        }
    }
}
