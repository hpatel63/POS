import Foundation
import ComposableArchitecture

struct ServiceContainer {
    var persistence: PersistenceController
    var payment: PaymentService
    var ocr: OCRService
    var sync: SyncService
    var ai: AIService
    var pdf: DocumentGenerationService
    var notification: NotificationSchedulerService

    static func live(persistence: PersistenceController) -> ServiceContainer {
        .init(
            persistence: persistence,
            payment: PaymentServiceLive(),
            ocr: OCRServiceLive(),
            sync: SyncServiceLive(),
            ai: AIServiceLive(),
            pdf: DocumentGenerationServiceLive(),
            notification: NotificationSchedulerServiceLive()
        )
    }
}

private enum ServicesKey: DependencyKey {
    static let liveValue: ServiceContainer = ServiceContainer.live(persistence: .shared)
}

extension DependencyValues {
    var services: ServiceContainer {
        get { self[ServicesKey.self] }
        set { self[ServicesKey.self] = newValue }
    }
}

private enum PersistenceKey: DependencyKey {
    static let liveValue: PersistenceController = .shared
}

extension DependencyValues {
    var persistenceController: PersistenceController {
        get { self[PersistenceKey.self] }
        set { self[PersistenceKey.self] = newValue }
    }
}

struct UUIDGenerator {
    var next: @Sendable () -> UUID
}

private enum UUIDGeneratorKey: DependencyKey {
    static let liveValue = UUIDGenerator(next: { UUID() })
}

extension DependencyValues {
    var uuid: UUIDGenerator {
        get { self[UUIDGeneratorKey.self] }
        set { self[UUIDGeneratorKey.self] = newValue }
    }
}

struct DateGenerator {
    var current: @Sendable () -> Date

    func now() -> Date { current() }
    func callAsFunction() -> Date { current() }
}

private enum DateGeneratorKey: DependencyKey {
    static let liveValue = DateGenerator(current: Date.init)
}

extension DependencyValues {
    var date: DateGenerator {
        get { self[DateGeneratorKey.self] }
        set { self[DateGeneratorKey.self] = newValue }
    }
}
