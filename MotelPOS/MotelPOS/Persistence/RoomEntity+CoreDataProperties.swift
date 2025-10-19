import Foundation
import CoreData

extension RoomEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<RoomEntity> {
        return NSFetchRequest<RoomEntity>(entityName: "RoomEntity")
    }

    @NSManaged public var id: UUID
    @NSManaged public var propertyID: UUID
    @NSManaged public var number: String
    @NSManaged public var floor: Int16
    @NSManaged public var building: String?
    @NSManaged public var type: String
    @NSManaged public var smoking: Bool
    @NSManaged public var beds: Int16
    @NSManaged public var notes: String?
    @NSManaged public var status: String
    @NSManaged public var createdAt: Date
    @NSManaged public var updatedAt: Date
    @NSManaged public var isDeleted: Bool
}
