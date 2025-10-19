import Foundation
import Combine

protocol NotificationSchedulerService {
    func scheduleDailyDigest(for config: DailyDigestConfig)
    func cancelNotifications(for propertyID: UUID)
    var digestPublisher: PassthroughSubject<DailyDigest, Never> { get }
}

struct DailyDigest: Codable, Equatable {
    var propertyID: UUID
    var date: Date
    var checkOuts: [String]
    var arrivals: [String]
    var salesSummary: [Payment.Method: Decimal]
    var outstandingBalances: Decimal
    var aiSummary: String
}

final class NotificationSchedulerServiceLive: NotificationSchedulerService {
    let digestPublisher = PassthroughSubject<DailyDigest, Never>()
    private var timers: [UUID: Timer] = [:]

    func scheduleDailyDigest(for config: DailyDigestConfig) {
        cancelNotifications(for: config.propertyID)
        let timer = Timer.scheduledTimer(withTimeInterval: 24 * 60 * 60, repeats: true) { [weak self] _ in
            guard let self else { return }
            let digest = DailyDigest(
                propertyID: config.propertyID,
                date: Date(),
                checkOuts: ["101 - 11:00", "205 - 12:00"],
                arrivals: ["302 - 16:00"],
                salesSummary: [.cash: 1200, .credit: 3400, .cashApp: 900],
                outstandingBalances: 230,
                aiSummary: "Occupancy 83%, revenue up 4% vs yesterday."
            )
            self.digestPublisher.send(digest)
        }
        timers[config.propertyID] = timer
    }

    func cancelNotifications(for propertyID: UUID) {
        timers[propertyID]?.invalidate()
        timers[propertyID] = nil
    }
}

struct NotificationSchedulerServiceMock: NotificationSchedulerService {
    let digestPublisher = PassthroughSubject<DailyDigest, Never>()
    func scheduleDailyDigest(for config: DailyDigestConfig) {}
    func cancelNotifications(for propertyID: UUID) {}
}
