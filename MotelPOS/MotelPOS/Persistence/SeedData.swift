import Foundation

enum SeedData {
    static let baseDate = Date(timeIntervalSince1970: 1_700_000_000)

    static let initialProperties: [Property] = {
        let property1 = Property(
            id: UUID(uuidString: "11111111-1111-1111-1111-111111111111")!,
            name: "Aurora Motel",
            code: "AUR",
            address: Address(line1: "123 Aurora Way", line2: nil, city: "Austin", state: "TX", postalCode: "78701", country: "USA"),
            phone: "512-555-1000",
            timezoneIdentifier: "America/Chicago",
            branding: Branding(primaryColor: "#0FF0FC", accentColor: "#9C6EFF", logoURL: nil, website: URL(string: "https://auroramotel.example")),
            taxProfileIDs: [],
            createdAt: baseDate,
            updatedAt: baseDate,
            isDeleted: false,
            retentionUntil: nil
        )
        let property2 = Property(
            id: UUID(uuidString: "22222222-2222-2222-2222-222222222222")!,
            name: "Neon Lodge",
            code: "NEO",
            address: Address(line1: "987 Spectrum Blvd", line2: "", city: "Phoenix", state: "AZ", postalCode: "85004", country: "USA"),
            phone: "602-555-2222",
            timezoneIdentifier: "America/Phoenix",
            branding: Branding(primaryColor: "#1E90FF", accentColor: "#FF2D95", logoURL: nil, website: URL(string: "https://neonlodge.example")),
            taxProfileIDs: [],
            createdAt: baseDate,
            updatedAt: baseDate,
            isDeleted: false,
            retentionUntil: nil
        )
        return [property1, property2]
    }()

    static let initialRooms: [Room] = {
        var rooms: [Room] = []
        for (index, property) in initialProperties.enumerated() {
            for roomNumber in 1...20 {
                let room = Room(
                    id: UUID(),
                    propertyID: property.id,
                    number: "\(100 + roomNumber)",
                    floor: (roomNumber - 1) / 10 + 1,
                    building: roomNumber <= 10 ? "A" : "B",
                    type: roomNumber % 5 == 0 ? .suite : .double,
                    smoking: roomNumber % 6 == 0,
                    beds: roomNumber % 3 == 0 ? 1 : 2,
                    notes: roomNumber % 7 == 0 ? "Accessible" : nil,
                    status: .available,
                    createdAt: baseDate,
                    updatedAt: baseDate,
                    isDeleted: false,
                    retentionUntil: nil
                )
                rooms.append(room)
            }
        }
        return rooms
    }()
}
