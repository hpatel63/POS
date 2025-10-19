import Foundation
import CoreData

extension PropertyEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<PropertyEntity> {
        return NSFetchRequest<PropertyEntity>(entityName: "PropertyEntity")
    }

    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var code: String
    @NSManaged public var phone: String?
    @NSManaged public var timezoneIdentifier: String?
    @NSManaged public var createdAt: Date
    @NSManaged public var updatedAt: Date
    @NSManaged public var isDeleted: Bool
    @NSManaged public var retentionUntil: NSDate?
    @NSManaged public var addressLine1: String?
    @NSManaged public var addressLine2: String?
    @NSManaged public var city: String?
    @NSManaged public var state: String?
    @NSManaged public var postalCode: String?
    @NSManaged public var country: String?
}
