import Foundation
import ComposableArchitecture

struct CheckInFeature: Reducer {
    struct State: Equatable, Identifiable {
        var id = UUID()
        var step: Step = .guestInfo
        var room: Room
        var checkInDate: Date
        var checkOutDate: Date = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        var guest = GuestInfo()
        var stay = StayInfo()
        var payment = PaymentInfo()
        var signatureData: Data? = nil
        var confirmationMessage: String? = nil
        var isProcessing = false
    }

    enum Step: Int, CaseIterable { case guestInfo, idScan, stay, payment, signature, confirmation }

    struct GuestInfo: Equatable {
        var firstName: String = ""
        var lastName: String = ""
        var email: String = ""
        var phone: String = ""
        var idNumber: String = ""
        var idState: String = ""
    }

    struct StayInfo: Equatable {
        var adults: Int = 1
        var children: Int = 0
        var pets: Int = 0
        var nightlyRate: Decimal = 139
        var taxRate: Decimal = 0.13
        var notes: String = ""
    }

    struct PaymentInfo: Equatable {
        var method: Payment.Method = .credit
        var amount: Decimal = 0
        var cardToken: String? = nil
        var cashAppHandle: String = "$auroramotel"
    }

    enum Action: Equatable {
        case nextStep
        case previousStep
        case updateGuest(GuestInfo)
        case updateStay(StayInfo)
        case updatePayment(PaymentInfo)
        case scanID(Data)
        case idScanResponse(Result<IDScanResult, Error>)
        case capturePayment
        case paymentResponse(Result<PaymentCaptureResponse, Error>)
        case completeSignature(Data)
        case finish
    }

    @Dependency(\.services) var services
    @Dependency(\.date) var date

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .nextStep:
                if state.step == .payment {
                    state.payment.amount = total(for: state)
                }
                state.step = Step(rawValue: state.step.rawValue + 1) ?? .confirmation
                return .none
            case .previousStep:
                state.step = Step(rawValue: max(0, state.step.rawValue - 1)) ?? .guestInfo
                return .none
            case let .updateGuest(info):
                state.guest = info
                return .none
            case let .updateStay(info):
                state.stay = info
                return .none
            case let .updatePayment(info):
                state.payment = info
                return .none
            case let .scanID(data):
                state.isProcessing = true
                return services.ocr.scanIDImage(data)
                    .map { .idScanResponse(.success($0)) }
                    .catch { Just(.idScanResponse(.failure($0))) }
                    .eraseToEffect()
            case let .idScanResponse(.success(result)):
                state.isProcessing = false
                state.guest.firstName = result.firstName
                state.guest.lastName = result.lastName
                state.guest.idNumber = result.idNumber
                state.guest.idState = result.issuingState
                state.guest.phone = ""
                return .none
            case .idScanResponse(.failure):
                state.isProcessing = false
                return .none
            case .capturePayment:
                state.isProcessing = true
                let request = PaymentCaptureRequest(reservationID: UUID(), amount: total(for: state), currency: "USD", method: state.payment.method)
                return services.payment.capture(payment: request)
                    .map { .paymentResponse(.success($0)) }
                    .catch { Just(.paymentResponse(.failure($0))) }
                    .eraseToEffect()
            case let .paymentResponse(.success(response)):
                state.isProcessing = false
                state.confirmationMessage = "Payment confirmed: \(response.confirmationCode)"
                state.step = .signature
                return .none
            case .paymentResponse(.failure):
                state.isProcessing = false
                state.confirmationMessage = "Payment failed"
                return .none
            case let .completeSignature(data):
                state.signatureData = data
                state.step = .confirmation
                state.confirmationMessage = "Reservation confirmed for \(state.guest.firstName)"
                return .none
            case .finish:
                return .none
            }
        }
    }

    func total(for state: State) -> Decimal {
        let nights = max(1, Calendar.current.dateComponents([.day], from: state.checkInDate, to: state.checkOutDate).day ?? 1)
        let subtotal = Decimal(nights) * state.stay.nightlyRate
        let taxes = subtotal * state.stay.taxRate
        return subtotal + taxes
    }
}
