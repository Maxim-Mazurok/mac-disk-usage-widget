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
}

struct DiskUsageWidgetCanvasPreview_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            DiskUsageWidgetView(
                entry: .previewWarning,
                previewFamilyOverride: .systemSmall,
                previewRenderingModeOverride: .fullColor
            )
                .frame(width: 170, height: 170)
                .previewDisplayName("Small - Full Color")

            DiskUsageWidgetView(
                entry: .previewWarning,
                previewFamilyOverride: .systemSmall,
                previewRenderingModeOverride: .accented
            )
                .frame(width: 170, height: 170)
                .previewDisplayName("Small - Accented")

            DiskUsageWidgetView(
                entry: .previewNormal,
                previewFamilyOverride: .systemMedium,
                previewRenderingModeOverride: .accented
            )
                .frame(width: 360, height: 170)
                .previewDisplayName("Medium - Accented")

            DiskUsageWidgetView(
                entry: .previewNormal,
                previewFamilyOverride: .systemLarge,
                previewRenderingModeOverride: .fullColor
            )
                .frame(width: 360, height: 380)
                .previewDisplayName("Large - Full Color")
        }
        .padding()
        .background(Color(nsColor: .windowBackgroundColor))
    }
}
#endif
