import Foundation
import ComposableArchitecture

struct HousekeepingFeature: Reducer {
    struct State: Equatable {
        var rooms: [Room] = SeedData.initialRooms
        var selectedPropertyID: UUID? = SeedData.initialProperties.first?.id
        var tasks: [HousekeepingTask] = HousekeepingTask.demo
        var aiSummary: String? = nil
    }

    struct HousekeepingTask: Identifiable, Equatable {
        var id = UUID()
        var roomNumber: String
        var description: String
        var dueDate: Date
        var completed: Bool
        static let demo: [HousekeepingTask] = [
            HousekeepingTask(roomNumber: "101", description: "Clean and restock", dueDate: Date(), completed: false),
            HousekeepingTask(roomNumber: "205", description: "Inspect smoke detector", dueDate: Date(), completed: false)
        ]
    }

    enum Action: Equatable {
        case toggleRoom(Room)
        case toggleTask(UUID)
        case load
        case aiSummary
        case aiSummaryResponse(Result<AIInsight, Error>)
    }

    @Dependency(\.services) var services

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case let .toggleRoom(room):
                if let index = state.rooms.firstIndex(where: { $0.id == room.id }) {
                    var updated = state.rooms[index]
                    updated.status = updated.status == .dirty ? .available : .dirty
                    state.rooms[index] = updated
                }
                return .none
            case let .toggleTask(id):
                if let index = state.tasks.firstIndex(where: { $0.id == id }) {
                    state.tasks[index].completed.toggle()
                }
                return .none
            case .load:
                return .none
            case .aiSummary:
                return services.ai.analyzeAnomalies(for: PropertyMetrics(propertyID: state.selectedPropertyID, occupancy: 0.65, adr: 118, revPAR: 88, revenueMix: [.cash: 900], upcomingCheckIns: 6, upcomingCheckOuts: 4, outOfServiceRooms: 2, timestamp: Date()))
                    .map { .aiSummaryResponse(.success($0)) }
                    .catch { Just(.aiSummaryResponse(.failure($0))) }
                    .eraseToEffect()
            case let .aiSummaryResponse(.success(insight)):
                state.aiSummary = insight.message
                return .none
            case .aiSummaryResponse(.failure):
                state.aiSummary = ""
                return .none
            }
        }
    }
}
