import Foundation
import Combine

protocol PaymentService {
    func tokenizeCard(_ number: String, expiry: String, cvv: String) -> AnyPublisher<String, Error>
    func capture(payment request: PaymentCaptureRequest) -> AnyPublisher<PaymentCaptureResponse, Error>
    func generateCashAppQR(handle: String, amount: Decimal) -> URL?
}

struct PaymentCaptureRequest: Codable, Equatable {
    var reservationID: UUID
    var amount: Decimal
    var currency: String
    var method: Payment.Method
}

struct PaymentCaptureResponse: Codable, Equatable {
    var confirmationCode: String
    var capturedAt: Date
}

struct PaymentServiceLive: PaymentService {
    func tokenizeCard(_ number: String, expiry: String, cvv: String) -> AnyPublisher<String, Error> {
        let token = "tok_" + UUID().uuidString.replacingOccurrences(of: "-", with: "")
        return Just(token)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    func capture(payment request: PaymentCaptureRequest) -> AnyPublisher<PaymentCaptureResponse, Error> {
        let response = PaymentCaptureResponse(confirmationCode: "AUTH-\(Int.random(in: 1000...9999))", capturedAt: Date())
        return Just(response)
            .delay(for: .milliseconds(250), scheduler: RunLoop.main)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    func generateCashAppQR(handle: String, amount: Decimal) -> URL? {
        URL(string: "https://cash.app/\(handle)?amount=\(amount as NSDecimalNumber)")
    }
}

struct PaymentServiceMock: PaymentService {
    var resultToken: String
    var captureResponse: PaymentCaptureResponse

    func tokenizeCard(_ number: String, expiry: String, cvv: String) -> AnyPublisher<String, Error> {
        Just(resultToken)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    func capture(payment request: PaymentCaptureRequest) -> AnyPublisher<PaymentCaptureResponse, Error> {
        Just(captureResponse)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    func generateCashAppQR(handle: String, amount: Decimal) -> URL? {
        URL(string: "https://example.com/qr")
    }
}
