import XCTest
@testable import MotelPOS

final class ReportExportTests: XCTestCase {
    func testCSVGeneration() async throws {
        let feature = ReportsFeature()
        var state = ReportsFeature.State()
        state.selectedReport = .revenue
        state.exportFormat = .csv
        let summary = ReportSummary(title: "Test", metrics: ["Net": "$1000"])
        let url = try await feature.generateCSV(for: summary)
        let contents = try String(contentsOf: url)
        XCTAssertTrue(contents.contains("Net,$1000"))
    }
}
