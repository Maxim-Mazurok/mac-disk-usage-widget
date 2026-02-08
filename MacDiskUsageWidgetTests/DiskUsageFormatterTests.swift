import XCTest
@testable import MacDiskUsageWidget

final class DiskUsageFormatterTests: XCTestCase {
    func testStorageStringForZeroIsStable() {
        XCTAssertEqual(DiskUsageFormatter.storageString(for: 0), "0 KB")
    }

    func testStorageStringForPositiveBytesIsNonEmpty() {
        let value = DiskUsageFormatter.storageString(for: 1_073_741_824)

        XCTAssertFalse(value.isEmpty)
        XCTAssertTrue(value.contains(where: { $0.isLetter }))
    }

    func testRoundedStorageStringForZeroIsStable() {
        XCTAssertEqual(DiskUsageFormatter.roundedStorageString(for: 0), "0 KB")
    }

    func testRoundedStorageStringUsesWholeNumbers() {
        let oneAndHalfGiB = Int64(1_610_612_736)
        XCTAssertEqual(DiskUsageFormatter.roundedStorageString(for: oneAndHalfGiB), "2 GB")
    }

    func testPercentageStringClampsInputRange() {
        XCTAssertEqual(
            DiskUsageFormatter.percentageString(for: -1),
            DiskUsageFormatter.percentageString(for: 0)
        )
        XCTAssertEqual(
            DiskUsageFormatter.percentageString(for: 2),
            DiskUsageFormatter.percentageString(for: 1)
        )
    }

    func testUpdatedTimeStringIsNonEmpty() {
        let value = DiskUsageFormatter.updatedTimeString(from: Date(timeIntervalSince1970: 100))
        XCTAssertFalse(value.isEmpty)
    }
}
