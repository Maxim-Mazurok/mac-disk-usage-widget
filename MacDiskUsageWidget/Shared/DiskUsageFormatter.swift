import Foundation

enum DiskUsageFormatter {
    private struct StorageUnit {
        let bytes: Double
        let suffix: String
    }

    private static let roundedStorageUnits: [StorageUnit] = [
        StorageUnit(bytes: 1_125_899_906_842_624, suffix: "PB"),
        StorageUnit(bytes: 1_099_511_627_776, suffix: "TB"),
        StorageUnit(bytes: 1_073_741_824, suffix: "GB"),
        StorageUnit(bytes: 1_048_576, suffix: "MB"),
        StorageUnit(bytes: 1_024, suffix: "KB")
    ]

    private static func makeByteCountFormatter() -> ByteCountFormatter {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .binary
        formatter.allowedUnits = [.useKB, .useMB, .useGB, .useTB, .usePB]
        formatter.includesUnit = true
        formatter.isAdaptive = true
        formatter.zeroPadsFractionDigits = false
        return formatter
    }

    private static func makePercentFormatter() -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.maximumFractionDigits = 0
        formatter.minimumFractionDigits = 0
        return formatter
    }

    private static func makeWholeNumberFormatter() -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        formatter.minimumFractionDigits = 0
        formatter.usesGroupingSeparator = false
        return formatter
    }

    private static func makeUpdatedFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return formatter
    }

    static func storageString(for bytes: Int64) -> String {
        guard bytes > 0 else {
            return "0 KB"
        }

        return makeByteCountFormatter().string(fromByteCount: bytes)
    }

    static func roundedStorageString(for bytes: Int64) -> String {
        guard bytes > 0 else {
            return "0 KB"
        }

        let value = Double(bytes)
        let unit = roundedStorageUnits.first(where: { value >= $0.bytes }) ?? roundedStorageUnits.last!
        let roundedValue = max(value / unit.bytes, 1).rounded()
        let formattedValue = makeWholeNumberFormatter().string(from: NSNumber(value: roundedValue)) ?? "0"

        return "\(formattedValue) \(unit.suffix)"
    }

    static func percentageString(for fraction: Double) -> String {
        let clamped = min(max(fraction, 0), 1)
        let number = NSNumber(value: clamped)
        return makePercentFormatter().string(from: number) ?? "0%"
    }

    static func updatedTimeString(from date: Date) -> String {
        makeUpdatedFormatter().string(from: date)
    }
}
