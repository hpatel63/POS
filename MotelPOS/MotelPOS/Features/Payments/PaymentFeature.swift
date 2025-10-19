import Foundation
import ComposableArchitecture

struct PaymentFeature: Reducer {
    struct State: Equatable {
        var reservationID: UUID
        var amount: Decimal
        var method: Payment.Method = .credit
        var status: Payment.Status = .pending
        var confirmation: PaymentCaptureResponse?
        var errorMessage: String?
    }

    enum Action: Equatable {
        case setMethod(Payment.Method)
        case capture
        case captureResponse(Result<PaymentCaptureResponse, Error>)
    }

    @Dependency(\.services) var services

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case let .setMethod(method):
                state.method = method
                return .none
            case .capture:
                let request = PaymentCaptureRequest(reservationID: state.reservationID, amount: state.amount, currency: "USD", method: state.method)
                return services.payment.capture(payment: request)
                    .map { .captureResponse(.success($0)) }
                    .catch { Just(.captureResponse(.failure($0))) }
                    .eraseToEffect()
            case let .captureResponse(.success(response)):
                state.status = .captured
                state.confirmation = response
                return .none
            case let .captureResponse(.failure(error)):
                state.status = .pending
                state.errorMessage = error.localizedDescription
                return .none
            }
        }
    }
}
