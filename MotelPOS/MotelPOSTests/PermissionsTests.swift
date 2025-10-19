import XCTest
@testable import MotelPOS

final class PermissionsTests: XCTestCase {
    func testManagerHasVoidPermission() {
        let manager = Role(id: UUID(), name: "Manager", permissions: Permission.allCases)
        XCTAssertTrue(manager.permissions.contains(.voidTransactions))
    }

    func testAssociateLimitedPermissions() {
        let associate = Role(id: UUID(), name: "Associate", permissions: [.managePayments, .manageHousekeeping])
        XCTAssertFalse(associate.permissions.contains(.manageUsers))
    }
}
