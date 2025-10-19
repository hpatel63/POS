import Foundation
import ComposableArchitecture

struct OfflineFeature: Reducer {
    struct State: Equatable {
        var isOnline: Bool = true
        var lastSync: Date? = nil
        var pendingItems: Int = 0
    }

    enum Action: Equatable {
        case appLaunched
        case syncNow
        case syncResponse(Result<SyncResult, Error>)
        case connectivityChanged(Bool)
    }

    @Dependency(\.services) var services

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .appLaunched:
                return .merge(
                    .run { send in
                        for await status in services.sync.isOnline.values {
                            await send(.connectivityChanged(status))
                        }
                    }
                    .cancellable(id: CancelID.connectivity, cancelInFlight: true),
                    .send(.syncNow)
                )
            case .syncNow:
                return services.sync.flushQueue()
                    .map { .syncResponse(.success($0)) }
                    .catch { Just(.syncResponse(.failure($0))) }
                    .eraseToEffect()
            case let .syncResponse(.success(result)):
                state.lastSync = Date()
                state.pendingItems = max(0, state.pendingItems - result.pushed)
                return .none
            case .syncResponse(.failure):
                state.pendingItems += 1
                return .none
            case let .connectivityChanged(isOnline):
                state.isOnline = isOnline
                return isOnline ? .send(.syncNow) : .none
            }
        }
    }

    private enum CancelID { case connectivity }
}
