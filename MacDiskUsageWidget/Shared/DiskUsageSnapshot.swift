import Foundation

struct DiskUsageSnapshot: Equatable, Sendable {
    let totalBytes: Int64
    let usedBytes: Int64
    let freeBytes: Int64
    let usedFraction: Double
    let timestamp: Date
    let volumeName: String

    var isAvailable: Bool {
        totalBytes > 0
    }

    static func unavailable(timestamp: Date = Date(), volumeName: String = "System") -> DiskUsageSnapshot {
        DiskUsageSnapshot(
            totalBytes: 0,
            usedBytes: 0,
            freeBytes: 0,
            usedFraction: 0,
            timestamp: timestamp,
            volumeName: volumeName
        )
    }
}
