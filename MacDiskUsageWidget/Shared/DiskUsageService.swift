import Foundation

protocol DiskUsageService: Sendable {
    func fetchSystemVolumeUsage() throws -> DiskUsageSnapshot
}

enum DiskUsageServiceError: LocalizedError {
    case missingSystemSize
    case missingFreeSize

    var errorDescription: String? {
        switch self {
        case .missingSystemSize:
            return "System volume size is unavailable."
        case .missingFreeSize:
            return "System volume free space is unavailable."
        }
    }
}
