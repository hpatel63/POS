import Foundation
import Combine

protocol OCRService {
    func scanIDImage(_ data: Data) -> AnyPublisher<IDScanResult, Error>
}

struct IDScanResult: Codable, Equatable {
    var firstName: String
    var lastName: String
    var address: Address
    var idNumber: String
    var issuingState: String
    var expiration: Date
}

struct OCRServiceLive: OCRService {
    func scanIDImage(_ data: Data) -> AnyPublisher<IDScanResult, Error> {
        let result = IDScanResult(
            firstName: "Demo",
            lastName: "Guest",
            address: Address(line1: "1 Main St", line2: nil, city: "Austin", state: "TX", postalCode: "78701", country: "USA"),
            idNumber: "D1234567",
            issuingState: "TX",
            expiration: Calendar.current.date(byAdding: .year, value: 5, to: Date())!
        )
        return Just(result)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}

struct OCRServiceMock: OCRService {
    var result: IDScanResult
    func scanIDImage(_ data: Data) -> AnyPublisher<IDScanResult, Error> {
        Just(result)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
