import AppIntents
import SwiftUI
import WidgetKit

struct DiskUsageWidgetView: View {
    let entry: DiskUsageEntry
    let previewFamilyOverride: WidgetFamily?
    let previewRenderingModeOverride: WidgetRenderingMode?

    @Environment(\.widgetFamily) private var family

    init(
        entry: DiskUsageEntry,
        previewFamilyOverride: WidgetFamily? = nil,
        previewRenderingModeOverride: WidgetRenderingMode? = nil
    ) {
        self.entry = entry
        self.previewFamilyOverride = previewFamilyOverride
        self.previewRenderingModeOverride = previewRenderingModeOverride
    }

    var body: some View {
        Group {
            if entry.snapshot.isAvailable {
                availableContent
            } else {
                unavailableContent
            }
        }
        .padding(12)
        .containerBackground(.regularMaterial, for: .widget)
    }

    @ViewBuilder
    private var availableContent: some View {
        switch previewFamilyOverride ?? family {
        case .systemSmall:
            smallContent
        case .systemMedium:
            mediumContent
        case .systemLarge, .systemExtraLarge:
            largeContent
        @unknown default:
            mediumContent
        }
    }

    private var smallContent: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline) {
                Text(DiskUsageFormatter.percentageString(for: entry.snapshot.usedFraction))
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(entry.severity.color)

                Spacer()

                refreshIconButton
            }

            usageProgressBar

            metricRow(title: "Used", value: DiskUsageFormatter.roundedStorageString(for: entry.snapshot.usedBytes))
            metricRow(title: "Free", value: DiskUsageFormatter.roundedStorageString(for: entry.snapshot.freeBytes))
            metricRow(title: "Total", value: DiskUsageFormatter.roundedStorageString(for: entry.snapshot.totalBytes))

            Spacer(minLength: 0)
        }
    }

    private var mediumContent: some View {
        HStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 8) {
                Text(DiskUsageFormatter.percentageString(for: entry.snapshot.usedFraction))
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundStyle(entry.severity.color)

                usageProgressBar

                Spacer(minLength: 0)

                refreshTextButton
            }

            Divider()

            VStack(alignment: .leading, spacing: 8) {
                metricRow(title: "Total", value: DiskUsageFormatter.roundedStorageString(for: entry.snapshot.totalBytes))
                metricRow(title: "Used", value: DiskUsageFormatter.roundedStorageString(for: entry.snapshot.usedBytes))
                metricRow(title: "Free", value: DiskUsageFormatter.roundedStorageString(for: entry.snapshot.freeBytes))
                metricRow(title: "Percent", value: DiskUsageFormatter.percentageString(for: entry.snapshot.usedFraction))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var largeContent: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Disk Usage")
                        .font(.headline)

                    Text(entry.snapshot.volumeName)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                refreshTextButton
            }

            Text(DiskUsageFormatter.percentageString(for: entry.snapshot.usedFraction))
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundStyle(entry.severity.color)

            usageProgressBar

            VStack(spacing: 12) {
                metricPairRow(
                    leftTitle: "Total",
                    leftValue: DiskUsageFormatter.roundedStorageString(for: entry.snapshot.totalBytes),
                    rightTitle: "Used",
                    rightValue: DiskUsageFormatter.roundedStorageString(for: entry.snapshot.usedBytes)
                )
                .frame(maxHeight: .infinity)

                metricPairRow(
                    leftTitle: "Free",
                    leftValue: DiskUsageFormatter.roundedStorageString(for: entry.snapshot.freeBytes),
                    rightTitle: "Percent Used",
                    rightValue: DiskUsageFormatter.percentageString(for: entry.snapshot.usedFraction)
                )
                .frame(maxHeight: .infinity)
            }
            .frame(maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private var unavailableContent: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Disk Usage")
                .font(.headline)
            Text("Unavailable")
                .font(.title3.weight(.semibold))
                .foregroundStyle(.secondary)
            Text("Unable to read system volume statistics.")
                .font(.caption)
                .foregroundStyle(.secondary)
            Spacer(minLength: 0)
            refreshTextButton
        }
    }

    private func metricRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.caption.weight(.semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
    }

    private var usageProgressBar: some View {
        WidgetProgressBar(
            value: normalizedUsageFraction,
            height: 8,
            fullColorFill: entry.severity.color,
            renderingModeOverride: previewRenderingModeOverride
        )
            .frame(maxWidth: .infinity)
    }

    private var normalizedUsageFraction: Double {
        min(max(entry.snapshot.usedFraction, 0), 1)
    }

    private var refreshIconButton: some View {
        Group {
            if Self.isRunningInPreview {
                Image(systemName: "arrow.clockwise")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            } else {
                Button(intent: RefreshDiskUsageIntent()) {
                    Image(systemName: "arrow.clockwise")
                        .font(.caption.weight(.semibold))
                }
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)
            }
        }
    }

    private var refreshTextButton: some View {
        Group {
            if Self.isRunningInPreview {
                Label("Refresh", systemImage: "arrow.clockwise")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            } else {
                Button(intent: RefreshDiskUsageIntent()) {
                    Label("Refresh", systemImage: "arrow.clockwise")
                        .font(.caption.weight(.semibold))
                }
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)
            }
        }
    }

    private func metricPairRow(leftTitle: String, leftValue: String, rightTitle: String, rightValue: String) -> some View {
        HStack(spacing: 16) {
            metricColumn(title: leftTitle, value: leftValue)
            metricColumn(title: rightTitle, value: rightValue)
        }
    }

    private func metricColumn(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.title3.weight(.semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }

    private static var isRunningInPreview: Bool {
        ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }
}

private struct WidgetProgressBar: View {
    let value: Double
    let height: CGFloat
    let fullColorFill: Color
    let renderingModeOverride: WidgetRenderingMode?

    @Environment(\.widgetRenderingMode) private var renderingMode

    var body: some View {
        GeometryReader { geometry in
            let clampedValue = min(max(value, 0), 1)
            let rawFillWidth = geometry.size.width * clampedValue
            let fillWidth = clampedValue > 0 ? max(rawFillWidth, 1) : 0

            ZStack(alignment: .leading) {
                Capsule(style: .circular)
                    .fill(.secondary.opacity(trackOpacity))
                    .widgetAccentable(false)

                Capsule(style: .circular)
                    .fill(fillColor)
                    .widgetAccentable()
                    .frame(width: fillWidth)
            }
            .frame(height: height)
        }
        .frame(height: height)
        .accessibilityLabel("Disk usage progress")
        .accessibilityValue("\(Int((min(max(value, 0), 1) * 100).rounded()))%")
    }

    private var fillColor: Color {
        effectiveRenderingMode == .fullColor ? fullColorFill : .primary
    }

    private var trackOpacity: Double {
        if effectiveRenderingMode == .accented || effectiveRenderingMode == .vibrant {
            return 0.35
        }

        return 0.22
    }

    private var effectiveRenderingMode: WidgetRenderingMode {
        renderingModeOverride ?? renderingMode
    }
}

private extension UsageSeverity {
    var color: Color {
        switch self {
        case .normal:
            return .green
        case .warning:
            return .yellow
        case .critical:
            return .red
        }
    }
}
