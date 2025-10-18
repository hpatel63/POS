import XCTest

final class MotelPOSUITests: XCTestCase {
    func testLaunch() throws {
        let app = XCUIApplication()
        app.launch()
        XCTAssertTrue(app.otherElements["MotelPOS"].exists || app.staticTexts["MotelPOS"].exists)
    }
}
