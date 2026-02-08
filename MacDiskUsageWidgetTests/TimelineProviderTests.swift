import Foundation
import WidgetKit
import XCTest
@testable import MacDiskUsageWidget

private struct MockDiskUsageService: DiskUsageService {
    let result: Result<DiskUsageSnapshot, Error>

    func fetchSystemVolumeUsage() throws -> DiskUsageSnapshot {
        try result.get()
    }
}

private enum MockError: Error {
    case failure
}

final class TimelineProviderTests: XCTestCase {
    func testLoadEntryReturnsServiceData() {
        let now = Date(timeIntervalSince1970: 1_000)
        let snapshot = DiskUsageSnapshot(
            totalBytes: 1_000,
            usedBytes: 800,
            freeBytes: 200,
            usedFraction: 0.8,
            timestamp: now,
            volumeName: "System"
        )

        let provider = DiskUsageTimelineProvider(
            service: MockDiskUsageService(result: .success(snapshot)),
            refreshInterval: 30,
            now: { now }
        )

        let entry = provider.loadEntry(at: now)
        XCTAssertEqual(entry.snapshot, snapshot)
        XCTAssertEqual(entry.severity, .warning)
        XCTAssertEqual(entry.date, now)
    }

    func testLoadEntryFallsBackToUnavailableOnError() {
        let now = Date(timeIntervalSince1970: 2_000)
        let provider = DiskUsageTimelineProvider(
            service: MockDiskUsageService(result: .failure(MockError.failure)),
            refreshInterval: 30,
            now: { now }
        )

        let entry = provider.loadEntry(at: now)
        XCTAssertFalse(entry.snapshot.isAvailable)
        XCTAssertEqual(entry.date, now)
    }

    func testMakeTimelineUsesThirtySecondRefreshPolicy() {
        let now = Date(timeIntervalSince1970: 3_000)
        let entry = DiskUsageEntry(
            date: now,
            snapshot: DiskUsageSnapshot(
                totalBytes: 1_000,
                usedBytes: 500,
                freeBytes: 500,
                usedFraction: 0.5,
                timestamp: now,
                volumeName: "System"
            ),
            severity: .normal
        )

        let provider = DiskUsageTimelineProvider(
            service: MockDiskUsageService(result: .success(entry.snapshot)),
            refreshInterval: 30,
            now: { now }
        )

        let timeline = provider.makeTimeline(from: entry)

        XCTAssertEqual(timeline.entries.count, 1)
        XCTAssertEqual(timeline.policy, .after(now.addingTimeInterval(30)))
    }
}
