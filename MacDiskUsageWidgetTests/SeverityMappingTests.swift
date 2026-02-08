import XCTest
@testable import MacDiskUsageWidget

final class SeverityMappingTests: XCTestCase {
    func testSeverityBelowWarningThresholdIsNormal() {
        XCTAssertEqual(UsageSeverity(fraction: 0.6999), .normal)
    }

    func testSeverityAtLowerBoundaryIsWarning() {
        XCTAssertEqual(UsageSeverity(fraction: 0.70), .warning)
    }

    func testSeverityAtUpperBoundaryIsWarning() {
        XCTAssertEqual(UsageSeverity(fraction: 0.85), .warning)
    }

    func testSeverityAboveUpperBoundaryIsCritical() {
        XCTAssertEqual(UsageSeverity(fraction: 0.8501), .critical)
    }
}
