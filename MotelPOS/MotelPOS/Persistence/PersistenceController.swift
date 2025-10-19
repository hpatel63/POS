import Foundation
import CoreData

final class PersistenceController {
    static let shared = PersistenceController()

    private let container: NSPersistentContainer
    private init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "MotelPOS")
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Unresolved error \(error)")
            }
        }
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.automaticallyMergesChangesFromParent = true
        seedIfNeeded(context: container.viewContext)
    }

    func newBackgroundContext() -> NSManagedObjectContext {
        let context = container.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
        return context
    }

    var viewContext: NSManagedObjectContext { container.viewContext }

    func save(context: NSManagedObjectContext) {
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch {
            context.rollback()
            print("Persistence save error: \(error)")
        }
    }

    private func seedIfNeeded(context: NSManagedObjectContext) {
        let request = NSFetchRequest<NSManagedObject>(entityName: "PropertyEntity")
        if (try? context.count(for: request)) ?? 0 > 0 {
            return
        }
        SeedData.initialProperties.forEach { property in
            let entity = PropertyEntity(context: context)
            entity.id = property.id
            entity.name = property.name
            entity.code = property.code
            entity.phone = property.phone
            entity.timezoneIdentifier = property.timezoneIdentifier
            entity.createdAt = property.createdAt
            entity.updatedAt = property.updatedAt
            entity.isDeleted = property.isDeleted
            entity.retentionUntil = property.retentionUntil as NSDate?
            entity.addressLine1 = property.address.line1
            entity.addressLine2 = property.address.line2
            entity.city = property.address.city
            entity.state = property.address.state
            entity.postalCode = property.address.postalCode
            entity.country = property.address.country
        }
        SeedData.initialRooms.forEach { room in
            let entity = RoomEntity(context: context)
            entity.id = room.id
            entity.propertyID = room.propertyID
            entity.number = room.number
            entity.floor = Int16(room.floor)
            entity.building = room.building
            entity.type = room.type.rawValue
            entity.smoking = room.smoking
            entity.beds = Int16(room.beds)
            entity.status = room.status.rawValue
            entity.createdAt = room.createdAt
            entity.updatedAt = room.updatedAt
            entity.isDeleted = room.isDeleted
        }
        save(context: context)
    }
}
