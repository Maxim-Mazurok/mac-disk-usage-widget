import SwiftUI
import WidgetKit

#if DEBUG
private extension DiskUsageEntry {
    static var previewNormal: DiskUsageEntry {
        let snapshot = DiskUsageSnapshot(
            totalBytes: 1_099_511_627_776,
            usedBytes: 472_446_402_560,
            freeBytes: 627_065_225_216,
            usedFraction: 0.43,
            timestamp: .now,
            volumeName: "Macintosh HD"
        )

        return DiskUsageEntry(date: .now, snapshot: snapshot, severity: .normal)
    }

    static var previewWarning: DiskUsageEntry {
        let snapshot = DiskUsageSnapshot(
            totalBytes: 1_099_511_627_776,
            usedBytes: 868_761_370_214,
            freeBytes: 230_750_257_562,
            usedFraction: 0.79,
            timestamp: .now,
            volumeName: "Macintosh HD"
        )

        return DiskUsageEntry(date: .now, snapshot: snapshot, severity: .warning)
    }

    static var previewCritical: DiskUsageEntry {
        let snapshot = DiskUsageSnapshot(
            totalBytes: 1_099_511_627_776,
            usedBytes: 1_053_963_996_171,
            freeBytes: 45_547_631_605,
            usedFraction: 0.96,
            timestamp: .now,
            volumeName: "Macintosh HD"
        )

        return DiskUsageEntry(date: .now, snapshot: snapshot, severity: .critical)
    }
}

private enum PreviewTheme: String, CaseIterable, Identifiable {
    case light
    case dark

    var id: String { rawValue }

    var colorScheme: ColorScheme {
        switch self {
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }

    var displayName: String {
        rawValue.capitalized
    }
}

private enum PreviewSeverity: String, CaseIterable, Identifiable {
    case normal
    case warning
    case critical

    var id: String { rawValue }

    var entry: DiskUsageEntry {
        switch self {
        case .normal:
            return .previewNormal
        case .warning:
            return .previewWarning
        case .critical:
            return .previewCritical
        }
    }

    var displayName: String {
        rawValue.capitalized
    }
}

private enum PreviewSize: String, CaseIterable, Identifiable {
    case small
    case medium
    case large

    var id: String { rawValue }

    var family: WidgetFamily {
        switch self {
        case .small:
            return .systemSmall
        case .medium:
            return .systemMedium
        case .large:
            return .systemLarge
        }
    }

    var frameSize: CGSize {
        switch self {
        case .small:
            return CGSize(width: 170, height: 170)
        case .medium:
            return CGSize(width: 360, height: 170)
        case .large:
            return CGSize(width: 360, height: 380)
        }
    }

    var displayName: String {
        rawValue.capitalized
    }
}

struct DiskUsageWidgetCanvasPreview_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ForEach(PreviewTheme.allCases) { theme in
                ForEach(PreviewSeverity.allCases) { severity in
                    ForEach(PreviewSize.allCases) { size in
                        DiskUsageWidgetView(
                            entry: severity.entry,
                            previewFamilyOverride: size.family,
                            previewRenderingModeOverride: .fullColor
                        )
                        .frame(width: size.frameSize.width, height: size.frameSize.height)
                        .preferredColorScheme(theme.colorScheme)
                        .previewDisplayName("\(theme.displayName) - \(size.displayName) - \(severity.displayName)")
                    }
                }
            }
        }
        .padding()
        .background(Color(nsColor: .windowBackgroundColor))
    }
}
#endif
