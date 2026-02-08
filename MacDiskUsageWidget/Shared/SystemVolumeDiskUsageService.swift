import Foundation

struct SystemVolumeDiskUsageService: DiskUsageService {
    static let systemPath = "/"

    func fetchSystemVolumeUsage() throws -> DiskUsageSnapshot {
        let attributes = try FileManager.default.attributesOfFileSystem(forPath: Self.systemPath)
        let totalBytes = (attributes[.systemSize] as? NSNumber)?.int64Value
        let freeBytes = (attributes[.systemFreeSize] as? NSNumber)?.int64Value

        guard let totalBytes else {
            throw DiskUsageServiceError.missingSystemSize
        }

        guard let freeBytes else {
            throw DiskUsageServiceError.missingFreeSize
        }

        let volumeName = Self.fetchVolumeName(for: Self.systemPath)

        return Self.makeSnapshot(
            totalBytes: totalBytes,
            freeBytes: freeBytes,
            timestamp: Date(),
            volumeName: volumeName
        )
    }

    static func makeSnapshot(totalBytes: Int64, freeBytes: Int64, timestamp: Date, volumeName: String) -> DiskUsageSnapshot {
        guard totalBytes > 0 else {
            return .unavailable(timestamp: timestamp, volumeName: volumeName)
        }

        let clampedFree = min(max(freeBytes, 0), totalBytes)
        let usedBytes = max(totalBytes - clampedFree, 0)
        let usedFraction = min(max(Double(usedBytes) / Double(totalBytes), 0), 1)

        return DiskUsageSnapshot(
            totalBytes: totalBytes,
            usedBytes: usedBytes,
            freeBytes: clampedFree,
            usedFraction: usedFraction,
            timestamp: timestamp,
            volumeName: volumeName
        )
    }

    private static func fetchVolumeName(for path: String) -> String {
        let url = URL(fileURLWithPath: path)
        let values = try? url.resourceValues(forKeys: [.volumeNameKey])
        if let volumeName = values?.volumeName, !volumeName.isEmpty {
            return volumeName
        }

        return "System"
    }
}
