import Foundation
import ComposableArchitecture

struct DashboardFeature: Reducer {
    struct State: Equatable {
        var properties: [Property] = SeedData.initialProperties
        var selectedPropertyID: UUID? = SeedData.initialProperties.first?.id
        var kpis: [KPI] = KPI.demo
        var aiEvents: [AIStreamEvent] = []
        var isStreamingInsight = false
        var query = ""
        var naturalLanguageResponse: String = ""
        var alerts: [AIInsight] = []
    }

    enum Action: Equatable {
        case selectProperty(UUID)
        case loadKPIs
        case updateKPIs([KPI])
        case fetchInsight
        case aiResponse(Result<AIStreamEvent, Error>)
        case updateQuery(String)
        case submitQuery
        case insightsResponse(Result<AIInsight, Error>)
        case anomaliesResponse(Result<AIInsight, Error>)
    }

    @Dependency(\.services) var services

    struct KPI: Equatable, Identifiable {
        enum Kind { case occupancy, adr, revPar, revenueMix, checkIns, checkOuts }
        var id = UUID()
        var title: String
        var value: String
        var subtitle: String
        var kind: Kind
        var propertyID: UUID?
        static let demo: [KPI] = [
            KPI(title: "Occupancy", value: "82%", subtitle: "Today", kind: .occupancy, propertyID: SeedData.initialProperties.first?.id),
            KPI(title: "ADR", value: "$132", subtitle: "Today", kind: .adr, propertyID: SeedData.initialProperties.first?.id),
            KPI(title: "RevPAR", value: "$108", subtitle: "MTD", kind: .revPar, propertyID: SeedData.initialProperties.first?.id),
            KPI(title: "Revenue Mix", value: "Cash 32% / Card 50% / Cash App 18%", subtitle: "Today", kind: .revenueMix, propertyID: SeedData.initialProperties.first?.id)
        ]
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case let .selectProperty(id):
                state.selectedPropertyID = id
                return .send(.loadKPIs)
            case .loadKPIs:
                let metrics = PropertyMetrics(
                    propertyID: state.selectedPropertyID,
                    occupancy: Double.random(in: 0.6...0.9),
                    adr: Double.random(in: 110...150),
                    revPAR: Double.random(in: 90...130),
                    revenueMix: [.cash: 1200, .credit: 3400, .cashApp: 900],
                    upcomingCheckIns: Int.random(in: 3...12),
                    upcomingCheckOuts: Int.random(in: 3...10),
                    outOfServiceRooms: Int.random(in: 0...3),
                    timestamp: Date()
                )
                state.isStreamingInsight = true
                state.aiEvents = []
                return .merge(
                    // ChatGPT Request Handler
                    .run { send in
                        try await withThrowingTaskGroup(of: Void.self) { group in
                            group.addTask {
                                for try await event in services.ai.streamInsight(for: AIRequest(query: "daily insight", context: [:], role: .manager)).values {
                                    await send(.aiResponse(.success(event)))
                                }
                            }
                        }
                    }
                    .cancellable(id: CancelID.stream, cancelInFlight: true),
                    services.ai.analyzeAnomalies(for: metrics)
                        .map { .anomaliesResponse(.success($0)) }
                        .catch { Just(.anomaliesResponse(.failure($0))) }
                        .eraseToEffect()
                )
            case let .aiResponse(.success(event)):
                state.aiEvents.append(event)
                if event.isFinal { state.isStreamingInsight = false }
                return .none
            case .aiResponse(.failure):
                state.isStreamingInsight = false
                return .none
            case let .updateKPIs(kpis):
                state.kpis = kpis
                return .none
            case let .updateQuery(query):
                state.query = query
                return .none
            case .submitQuery:
                guard !state.query.isEmpty else { return .none }
                state.naturalLanguageResponse = ""
                return .run { [query = state.query, propertyID = state.selectedPropertyID] send in
                    let events = services.ai.streamInsight(for: AIRequest(query: query, context: ["propertyID": propertyID?.uuidString ?? "all"], role: .manager))
                    for try await event in events.values {
                        await send(.aiResponse(.success(event)))
                    }
                }
            case let .insightsResponse(.success(insight)):
                state.alerts.append(insight)
                return .none
            case .insightsResponse(.failure):
                return .none
            case let .anomaliesResponse(.success(insight)):
                state.alerts.append(insight)
                return .none
            case .anomaliesResponse(.failure):
                return .none
            case .fetchInsight:
                return .send(.loadKPIs)
            }
        }
    }

    private enum CancelID { case stream }
}
