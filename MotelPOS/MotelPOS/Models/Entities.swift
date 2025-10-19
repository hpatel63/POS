import Foundation

struct Property: Identifiable, Hashable, Codable {
    var id: UUID
    var name: String
    var code: String
    var address: Address
    var phone: String
    var timezoneIdentifier: String
    var branding: Branding
    var taxProfileIDs: [UUID]
    var createdAt: Date
    var updatedAt: Date
    var isDeleted: Bool
    var retentionUntil: Date?
}

struct Address: Hashable, Codable {
    var line1: String
    var line2: String?
    var city: String
    var state: String
    var postalCode: String
    var country: String
}

struct Branding: Hashable, Codable {
    var primaryColor: String
    var accentColor: String
    var logoURL: URL?
    var website: URL?
}

struct Room: Identifiable, Hashable, Codable {
    var id: UUID
    var propertyID: UUID
    var number: String
    var floor: Int
    var building: String
    var type: RoomType
    var smoking: Bool
    var beds: Int
    var notes: String?
    var status: RoomStatus
    var createdAt: Date
    var updatedAt: Date
    var isDeleted: Bool
    var retentionUntil: Date?
}

enum RoomType: String, Codable, CaseIterable { case single, double, suite, deluxe }

enum RoomStatus: String, Codable, CaseIterable { case available, occupied, dirty, outOfService }

struct Guest: Identifiable, Hashable, Codable {
    var id: UUID
    var firstName: String
    var lastName: String
    var email: String?
    var phone: String?
    var loyaltyTier: String?
    var notes: [GuestIncident]
    var createdAt: Date
    var updatedAt: Date
    var isDeleted: Bool
    var retentionUntil: Date?
}

struct Reservation: Identifiable, Hashable, Codable {
    enum Status: String, Codable { case tentative, confirmed, checkedIn, checkedOut, cancelled, noShow }
    var id: UUID
    var propertyID: UUID
    var roomID: UUID
    var guestID: UUID
    var status: Status
    var checkInDate: Date
    var checkOutDate: Date
    var nightlyRate: Decimal
    var total: Decimal
    var balanceDue: Decimal
    var adults: Int
    var children: Int
    var pets: Int
    var paymentIDs: [UUID]
    var authorizationPacketURL: URL?
    var signatureHash: String?
    var documents: [Document]
    var createdAt: Date
    var updatedAt: Date
    var isDeleted: Bool
    var retentionUntil: Date?
}

struct Payment: Identifiable, Hashable, Codable {
    enum Method: String, Codable, CaseIterable { case cash, credit, debit, cashApp, pending }
    enum Status: String, Codable, CaseIterable { case authorized, captured, refunded, voided, pending }
    var id: UUID
    var reservationID: UUID
    var method: Method
    var amount: Decimal
    var status: Status
    var processorToken: String?
    var processorReference: String?
    var createdAt: Date
    var updatedAt: Date
    var isDeleted: Bool
    var retentionUntil: Date?
}

struct Document: Identifiable, Hashable, Codable {
    enum Kind: String, Codable { case idFront, idBack, signature, folio, receipt, authorization, taxPacket, manual }
    var id: UUID
    var reservationID: UUID?
    var propertyID: UUID?
    var kind: Kind
    var filename: String
    var url: URL
    var checksum: String
    var createdAt: Date
    var updatedAt: Date
    var isDeleted: Bool
    var retentionUntil: Date?
}

struct TaxProfile: Identifiable, Hashable, Codable {
    var id: UUID
    var name: String
    var jurisdiction: String
    var rate: Decimal
    var appliesTo: [String]
    var createdAt: Date
    var updatedAt: Date
    var isDeleted: Bool
    var retentionUntil: Date?
}

struct User: Identifiable, Hashable, Codable {
    var id: UUID
    var username: String
    var displayName: String
    var roleID: UUID
    var email: String
    var phone: String?
    var createdAt: Date
    var updatedAt: Date
    var isDeleted: Bool
    var retentionUntil: Date?
}

struct Role: Identifiable, Hashable, Codable {
    var id: UUID
    var name: String
    var permissions: [Permission]
}

enum Permission: String, Codable, CaseIterable, Hashable {
    case manageUsers
    case manageSettings
    case managePayments
    case manageReports
    case manageHousekeeping
    case runDailyClose
    case overrideRates
    case voidTransactions
    case manageAI
}

struct AuditLog: Identifiable, Hashable, Codable {
    enum EventType: String, Codable { case create, update, delete, aiQuery, login, sync }
    var id: UUID
    var actorID: UUID
    var entity: String
    var entityID: UUID
    var eventType: EventType
    var context: String
    var createdAt: Date
}

struct GuestIncident: Identifiable, Hashable, Codable {
    var id: UUID
    var guestID: UUID
    var propertyID: UUID
    var occurredOn: Date
    var summary: String
    var severity: Severity
    var createdAt: Date
    var updatedAt: Date
    var isDeleted: Bool
    var retentionUntil: Date?
    enum Severity: String, Codable { case info, warning, critical }
}

struct DailyDigestConfig: Identifiable, Hashable, Codable {
    var id: UUID
    var propertyID: UUID
    var sendTime: DateComponents
    var channels: [NotificationChannel]
    var createdAt: Date
    var updatedAt: Date
}

enum NotificationChannel: String, Codable { case inApp, push, email }

struct SyncEnvelope<T: Codable>: Codable {
    var data: [T]
    var lastSyncedAt: Date
}
