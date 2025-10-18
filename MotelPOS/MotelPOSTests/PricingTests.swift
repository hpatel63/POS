import XCTest
@testable import MotelPOS

final class PricingTests: XCTestCase {
    func testStayTotalCalculation() throws {
        let room = Room(id: UUID(), propertyID: SeedData.initialProperties.first!.id, number: "101", floor: 1, building: "A", type: .double, smoking: false, beds: 2, notes: nil, status: .available, createdAt: Date(), updatedAt: Date(), isDeleted: false, retentionUntil: nil)
        var state = CheckInFeature.State(room: room, checkInDate: Date())
        state.checkOutDate = Calendar.current.date(byAdding: .day, value: 3, to: state.checkInDate)!
        state.stay.nightlyRate = 100
        state.stay.taxRate = 0.1

        let total = CheckInFeature().total(for: state)
        XCTAssertEqual(total, 330)
    }
}
