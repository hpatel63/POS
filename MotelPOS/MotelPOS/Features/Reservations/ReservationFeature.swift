import Foundation
import ComposableArchitecture

struct ReservationFeature: Reducer {
    struct State: Equatable, Identifiable {
        var reservation: Reservation
        var id: UUID { reservation.id }
        var payments: [Payment] = []
        var documents: [Document] = []
        var incidents: [GuestIncident] = []
        var aiSuggestions: [AIInsight] = []
    }

    enum Action: Equatable {
        case load
        case exportFolio
        case exportAuthorization
        case close
        case aiSuggest
        case aiResponse(Result<AIInsight, Error>)
    }

    @Dependency(\.services) var services

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .load:
                state.payments = [
                    Payment(id: UUID(), reservationID: state.reservation.id, method: .credit, amount: 189.99, status: .captured, processorToken: nil, processorReference: "AUTH1234", createdAt: Date(), updatedAt: Date(), isDeleted: false, retentionUntil: nil)
                ]
                return .none
            case .exportFolio:
                do {
                    _ = try services.pdf.generateReceipt(for: state.reservation, property: SeedData.initialProperties.first!, payments: state.payments)
                } catch {}
                return .none
            case .exportAuthorization:
                do {
                    _ = try services.pdf.generateTaxPacket(for: SeedData.initialProperties.first!, reports: [])
                } catch {}
                return .none
            case .close:
                return .none
            case .aiSuggest:
                let metrics = PropertyMetrics(propertyID: state.reservation.propertyID, occupancy: 0.7, adr: Double(truncating: state.reservation.nightlyRate as NSNumber), revPAR: 90, revenueMix: [.credit: state.reservation.total], upcomingCheckIns: 4, upcomingCheckOuts: 5, outOfServiceRooms: 1, timestamp: Date())
                return services.ai.analyzeAnomalies(for: metrics)
                    .map { .aiResponse(.success($0)) }
                    .catch { Just(.aiResponse(.failure($0))) }
                    .eraseToEffect()
            case let .aiResponse(.success(insight)):
                state.aiSuggestions.append(insight)
                return .none
            case .aiResponse(.failure):
                return .none
            }
        }
    }
}
