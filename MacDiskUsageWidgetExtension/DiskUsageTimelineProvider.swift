import Foundation
import OSLog
import WidgetKit

struct DiskUsageEntry: TimelineEntry {
    let date: Date
    let snapshot: DiskUsageSnapshot
    let severity: UsageSeverity
}

struct DiskUsageTimelineProvider: TimelineProvider {
    let service: DiskUsageService
    let refreshInterval: TimeInterval
    let now: () -> Date

    private let logger = Logger(subsystem: "com.max.MacDiskUsageWidget", category: "WidgetTimeline")

    init(
        service: DiskUsageService = SystemVolumeDiskUsageService(),
        refreshInterval: TimeInterval = 30,
        now: @escaping () -> Date = Date.init
    ) {
        self.service = service
        self.refreshInterval = max(refreshInterval, 15)
        self.now = now
    }

    func placeholder(in context: Context) -> DiskUsageEntry {
        DiskUsageEntry(
            date: now(),
            snapshot: DiskUsageSnapshot(
                totalBytes: 512 * 1_024 * 1_024 * 1_024,
                usedBytes: 312 * 1_024 * 1_024 * 1_024,
                freeBytes: 200 * 1_024 * 1_024 * 1_024,
                usedFraction: 0.61,
                timestamp: now(),
                volumeName: "System"
            ),
            severity: .normal
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (DiskUsageEntry) -> Void) {
        completion(loadEntry(at: now()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<DiskUsageEntry>) -> Void) {
        let entry = loadEntry(at: now())
        completion(makeTimeline(from: entry))
    }

    func loadEntry(at date: Date) -> DiskUsageEntry {
        do {
            let snapshot = try service.fetchSystemVolumeUsage()
            return DiskUsageEntry(date: date, snapshot: snapshot, severity: UsageSeverity(fraction: snapshot.usedFraction))
        } catch {
            logger.error("Disk usage fetch failed for widget: \(error.localizedDescription, privacy: .public)")
            let fallback = DiskUsageSnapshot.unavailable(timestamp: date)
            return DiskUsageEntry(date: date, snapshot: fallback, severity: UsageSeverity(fraction: fallback.usedFraction))
        }
    }

    func makeTimeline(from entry: DiskUsageEntry) -> Timeline<DiskUsageEntry> {
        let nextRefresh = entry.date.addingTimeInterval(refreshInterval)
        return Timeline(entries: [entry], policy: .after(nextRefresh))
    }
}
