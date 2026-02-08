import XCTest
@testable import MacDiskUsageWidget

final class DiskUsageServiceTests: XCTestCase {
    func testMakeSnapshotComputesUsedAndFraction() {
        let snapshot = SystemVolumeDiskUsageService.makeSnapshot(
            totalBytes: 1_000,
            freeBytes: 250,
            timestamp: Date(timeIntervalSince1970: 100),
            volumeName: "System"
        )

        XCTAssertEqual(snapshot.totalBytes, 1_000)
        XCTAssertEqual(snapshot.freeBytes, 250)
        XCTAssertEqual(snapshot.usedBytes, 750)
        XCTAssertEqual(snapshot.usedFraction, 0.75, accuracy: 0.0001)
        XCTAssertTrue(snapshot.isAvailable)
    }

    func testMakeSnapshotClampsFreeAboveTotal() {
        let snapshot = SystemVolumeDiskUsageService.makeSnapshot(
            totalBytes: 500,
            freeBytes: 600,
            timestamp: Date(timeIntervalSince1970: 100),
            volumeName: "System"
        )

        XCTAssertEqual(snapshot.freeBytes, 500)
        XCTAssertEqual(snapshot.usedBytes, 0)
        XCTAssertEqual(snapshot.usedFraction, 0.0, accuracy: 0.0001)
    }

    func testMakeSnapshotReturnsUnavailableWhenTotalIsNotPositive() {
        let snapshot = SystemVolumeDiskUsageService.makeSnapshot(
            totalBytes: 0,
            freeBytes: 0,
            timestamp: Date(timeIntervalSince1970: 100),
            volumeName: "System"
        )

        XCTAssertFalse(snapshot.isAvailable)
        XCTAssertEqual(snapshot.totalBytes, 0)
        XCTAssertEqual(snapshot.usedBytes, 0)
        XCTAssertEqual(snapshot.freeBytes, 0)
    }

    func testFetchSystemVolumeUsageReturnsValidSnapshot() throws {
        let service = SystemVolumeDiskUsageService()
        let snapshot = try service.fetchSystemVolumeUsage()

        XCTAssertGreaterThan(snapshot.totalBytes, 0)
        XCTAssertGreaterThanOrEqual(snapshot.freeBytes, 0)
        XCTAssertGreaterThanOrEqual(snapshot.usedBytes, 0)
        XCTAssertGreaterThanOrEqual(snapshot.usedFraction, 0)
        XCTAssertLessThanOrEqual(snapshot.usedFraction, 1)
    }
}
